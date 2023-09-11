module CompassUtils

  SEVEN_DAYS = 7 * 24 * 60 * 60
  HALF_YEAR = 180 * 24 * 60 * 60
  ONE_YEAR = 2 * HALF_YEAR
  TWO_YEARS = 2 * ONE_YEAR
  FIVE_YEARS = 5 * ONE_YEAR

  def redirect_url(error: nil, default_url: nil, skip_cookies: false)
    default_host = Addressable::URI.parse(ENV['DEFAULT_HOST'])
    url = (defined?(cookies) && cookies['auth.callback-url'].presence) || default_url
    url = default_url if skip_cookies
    uri = Addressable::URI.parse(url)
    uri.scheme = default_host.scheme
    uri.host = default_host.host
    if error.present?
      uri.query_values = uri.query_values.to_h.merge({ error: error, ts: (Time.now.to_f * 1000).to_i })
    end
    uri.to_s
  end

  def auto_break_line(text, max_length: 30)
    broken_lines = []
    current_line = ''

    text.split.each do |word|
      if current_line.length + word.length <= max_length
        current_line += ' ' + word
      else
        broken_lines << current_line.strip
        current_line = word
      end
    end

    broken_lines << current_line.strip unless current_line.empty?
    broken_lines.join("\n")
  end

  def extract_date(begin_date, end_date)
    today = Date.today.end_of_day

    begin_date = begin_date || today - 3.months
    end_date = [end_date || today, today].min
    diff_seconds = end_date.to_i - begin_date.to_i

    if diff_seconds < SEVEN_DAYS
      begin_date = today - 3.months
      end_date = today
      interval = false
    elsif diff_seconds <= TWO_YEARS
      interval = false
    else
      interval = '1M'
    end
    [begin_date, end_date, interval]
  end

  def generate_interval_aggs(base_type, date_field, interval_str='1M', avg_type='Float', aliases={}, suffixs=[])
    metric_fields =
      base_type.fields.select{|k, v| v.type.name.end_with?(avg_type)}.keys.map(&:underscore)
    aggregate_inteval = {
      aggsWithDate: {
        date_histogram: {
          field: date_field,
          calendar_interval: interval_str
        },
        aggs: metric_fields.reduce({}) do |aggs, field|
          if suffixs.present?
            suffixs.reduce(aggs) do |results, suffix|
              results.merge({ "#{field}#{suffix}" => { avg: { field: "#{aliases[field]}#{suffix}" || "#{field}#{suffix}" } } })
            end
          else
            aggs.merge({ field => { avg: { field: aliases[field] || field } } })
          end
        end
      }
    }
  end
end
