class OpencheckRaw < BaseMetric
  include BaseModelMetric

  def self.index_name
    "opencheck_raw"
  end

  def self.mapping
    {
      properties: {
        id: { type: 'keyword' },
        status: { type: 'text' },
        grimoire_creation_date: { type: 'date' },
        project_url: {
          type: 'text',
          fields: {
            keyword: {
              type: 'keyword',
              ignore_above: 256
            }
          }
        },
        label:{type:"keyword"},
        command_result: {
          type: 'object',
          dynamic: 'false',
          properties: {}
        }
      }
    }
  end

  def self.ensure_index
    return if index_exists?
    create_index
    update_mapping
  rescue => e
    Rails.logger.error "[OpenSearch] Index operation error: #{e.class}: #{e.message}"
  end

  def self.save_opencheck_raw(command, command_result, project_url)
    ensure_index


    document_hash = {
      project_url: project_url,
      label: project_url,
      grimoire_creation_date: Time.now.utc.iso8601,
      command: command,
      command_result: command_result,
      id: SecureRandom.uuid,
      status: "success"
    }

    options = {
      index: index_name
    }
    document = OpenStruct.new(document_hash)

    index(document, options)
  end


end
