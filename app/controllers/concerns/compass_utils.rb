module CompassUtils
  include Director

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

  def get_uuid(*args)
    def check_value(v)
      if !v.is_a?(String)
        raise ValueError, "%s value is not a string instance" % v.to_s
      elsif v.empty?
        raise ValueError, "value cannot be None or empty"
      else
        return v
      end
    end

    def uuid(*args)
      s = args.map{ |arg| check_value(arg) }.join(':')
      sha1 = Digest::SHA1.hexdigest(s)
      return sha1
    end

    args_list = args.select { |arg| !arg.nil? && !arg.empty? }
    return uuid(*args_list)
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

  def extract_repos_source(label, level)
    repo_list = [label]
    if level == 'community'
      project = ProjectTask.find_by(project_name: label)
      repo_list = director_repo_list(project&.remote_url)
    end
    github_count, gitee_count = 0,0
    repo_list.each do |url|
      gitee_count += 1 if url =~ /gitee\.com/
      github_count += 1 if url =~ /github\.com/
    end
    if github_count > 0 && gitee_count == 0
      'github'
    elsif gitee_count > 0 && github_count == 0
      'gitee'
    else
      'combine'
    end
  end

  def select_idx_repos_by_lablel_and_level(label, level, gitee_idx, github_idx)
    if level == 'repo' && label =~ /gitee\.com/
      [gitee_idx, [label], 'gitee']
    elsif level == 'repo'&& label =~ /github\.com/
      [github_idx, [label], 'github']
    else
      project = ProjectTask.find_by(project_name: label)
      repo_list = director_repo_list(project&.remote_url)
      origin = extract_repos_source(label, level)
      [origin == 'gitee' ? gitee_idx : github_idx, repo_list, origin]
    end
  end

  def is_repo_admin?(current_user, label, level)
    Rails.cache.fetch("is_repo_admin:user-#{current_user.id}:#{level}:#{label}", expires_in: 15.minutes) do
      indexer, repo_urls, origin =
                          select_idx_repos_by_lablel_and_level(label, level, GiteeContributorEnrich, GithubContributorEnrich)
      username = LoginBind.current_host_nickname(current_user, origin)
      indexer.repo_admin?(username, repo_urls)
    end
  end

  def validate_date(current_user, label, level, begin_date, end_date)
    valid_range = [begin_date, end_date]
    default_min = Date.today - 1.month
    default_max = Date.today

    is_repo_admin = current_user&.is_admin? || is_repo_admin?(current_user, label, level)

    return [true, valid_range, is_repo_admin] if is_repo_admin

    diff_seconds = end_date.to_i - begin_date.to_i
    return [true, valid_range, is_repo_admin] if diff_seconds < 2.months

    return [true, valid_range, is_repo_admin] if current_user&.has_privilege_to?(label, level)

    [false, [default_min, default_max], is_repo_admin]
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
