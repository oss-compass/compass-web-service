module CompassUtils
  include Director

  HOURS = 60 * 60
  DAYS = 24 * HOURS
  SEVEN_DAYS = 7 * DAYS
  HALF_YEAR = 180 * DAYS
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
    github_count, gitee_count, gticode_count = 0,0,0
    repo_list.each do |url|
      gitee_count += 1 if url =~ /gitee\.com/
      github_count += 1 if url =~ /github\.com/
      gticode_count += 1 if url =~ /gitcode\.com/
    end
    counts = { 'github' => github_count, 'gitee' => gitee_count, 'gitcode' => gticode_count }
    max_pair = counts.max_by { |_, v| v }
    if max_pair[1] > 0 && counts.values.count(max_pair[1]) == 1
      max_pair[0]
    else
      'combine'
    end
  end

  def select_idx_repos_by_lablel_and_level(label, level, gitee_idx, github_idx, gitcode_idx = nil)
    gitcode_idx ||= github_idx
    # 定义仓库主机与对应索引、来源的映射关系
    repo_host_mapping = {
      'gitee.com'  => { idx: gitee_idx,  origin: 'gitee' },
      'github.com' => { idx: github_idx, origin: 'github' },
      'gitcode.com' => { idx: gitcode_idx, origin: 'gitcode' }
    }

    if level == 'repo'
      # 查找匹配的主机配置
      matched_host = repo_host_mapping.find { |host, _| label =~ /#{host}/ }
      if matched_host
        _, config = matched_host
        return [config[:idx], [label], config[:origin]]
      end
    end

    # 非仓库级别或未匹配到主机时的处理逻辑
    project = ProjectTask.find_by(project_name: label)
    repo_list = director_repo_list(project&.remote_url)
    origin = extract_repos_source(label, level)

    # 根据来源选择对应的索引
    selected_idx = case origin
                   when 'gitee' then gitee_idx
                   when 'gitcode' then gitcode_idx
                   else github_idx
                   end

    [selected_idx, repo_list, origin]
  end

  def is_repo_admin?(current_user, label, level)
    Rails.cache.fetch("is_repo_admin:user-#{current_user.id}:#{level}:#{label}", expires_in: 15.minutes) do
      indexer, repo_urls, origin =
                          select_idx_repos_by_lablel_and_level(label, level, GiteeContributorEnrich, GithubContributorEnrich, GitcodeContributorEnrich)
      username = LoginBind.current_host_nickname(current_user, origin)
      indexer.repo_admin?(username, repo_urls)
    end
  end

  def validate_date(current_user, label, level, begin_date, end_date)
    valid_range = [begin_date, end_date]
    default_min = Date.today - 1.year
    default_max = Date.today

    is_repo_admin = current_user&.is_admin? || is_repo_admin?(current_user, label, level)

    return [true, valid_range, is_repo_admin] if is_repo_admin

    diff_seconds = end_date.to_i - begin_date.to_i
    return [true, valid_range, is_repo_admin] if diff_seconds <= 1.year

    is_repo_admin = current_user&.has_privilege_to?(label, level)
    return [true, valid_range, is_repo_admin] if is_repo_admin

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

  def time_diff_hours(start_time_str, end_time_str)
    start_datetime = DateTime.parse(start_time_str)
    end_datetime = DateTime.parse(end_time_str)
    time_diff_seconds = (end_datetime - start_datetime) * HOURS
    days_diff = time_diff_seconds / HOURS
    format('%.2f', days_diff)
  end

end
