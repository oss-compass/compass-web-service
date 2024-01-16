class ExportTaskWorker
  include Sneakers::Worker

  from_queue 'export_task_v1',
             :ack => true,
             :timeout_job_after => 60,
             :retry_max_times => 3

  MAX_PER_PAGE = 2000

  def work(msg)
    message = JSON.parse(msg)
    label = message['label']
    level = message['level']
    uuid = message['uuid']
    query = message['query']
    select = message['select']
    indexer = message['indexer'].constantize
    raw_data = message['raw_data']
    callback_module = (message['callback_module']&.constantize) || indexer
    each_callback_function = message['each_callback_function'] || 'on_each'
    finish_callback_function = message['finish_callback_function'] || 'on_finish'
    per_page = message['per_page'] || MAX_PER_PAGE
    temp_csv_path = Rails.root.join("tmp/uploads/temp_#{uuid}.csv")
    Rails.cache.write("export-#{uuid}", { status: ::Subject::PROGRESS })

    begin
      CSV.open(temp_csv_path, 'wb') do |csv|
        csv << select

        if query.present?
          scroll_query = indexer.must([query]).per(per_page).scroll(timeout: '1m')
          loop do
            scroll_query.execute.raw_response.dig('hits', 'hits').map do |hit|
              csv << callback_module
                       .send(each_callback_function, { uuid: uuid, source: hit['_source'] })
                       .slice(*select)
                       .values
            end
            scroll_query = scroll_query.scroll(id: scroll_query.scroll_id, timeout: '1m')
            break if scroll_query.last_page?
          end
        elsif raw_data.present?
          raw_data.each do |row|
            csv << callback_module
                     .send(each_callback_function, { uuid: uuid, source: row })
                     .slice(*select)
                     .values
          end
        end
      end


      blob_id = nil
      subject = Subject.find_by(label: label, level: level)

      if subject.present?
        blob =
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(temp_csv_path),
            filename: "#{subject.short_name}.csv",
            content_type: 'text/csv',
          )
        blob_id = blob.id
        subject.exports.attach(blob.signed_id)
      end

      File.delete(temp_csv_path) if File.exist?(temp_csv_path)

      callback_module.send(finish_callback_function, { uuid: uuid, blob_id: blob_id })
    rescue => ex
      Rails.cache.write("export-#{uuid}", { status: ::Subject::UNKNOWN })
      Sneakers.logger.error "Failed to export, reason: #{ex.message}"
      raise ex
    end
    ack!
  end
end
