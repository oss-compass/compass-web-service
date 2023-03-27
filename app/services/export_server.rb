# frozen_string_literal: true
require 'csv'
require 'open3'

class ExportServer
  include Common
  include GithubApplication

  REPOS_CSV = 'all_repositories.csv'

  def initialize(index, field, batch_size, num_partitions)
    @index = index
    @field = field
    @batch_size = batch_size || 1000
    @num_partitions = num_partitions || 20
  end

  def execute
    export_repos_to_csv(REPOS_CSV)

    chdir = "#{Rails.root + META_REPO}"

    output, status = Open3.capture2('git pull', :chdir=>chdir)

    if !status.success?
      job_logger.error "failed to git pull latest, error: #{output}"
      return
    end

    output, status = Open3.capture2("git add #{REPOS_CSV}", :chdir=>chdir)
    if !status.success?
      job_logger.error "failed to git add #{REPOS_CSV}, error: #{output}"
      return
    end

    output, status = Open3.capture2("git commit -m 'Update at #{DateTime.now.to_s}'", :chdir=>chdir)
    if !status.success?
      job_logger.error "failed to git commit, error: #{output}"
      return
    end

    output, status = Open3.capture2("git config credential.username oss-compass-bot", :chdir=>chdir)
    if !status.success?
      job_logger.error "failed to git config credential.username, error: #{output}"
      return
    end

    output, status = Open3.capture2("git config credential.helper '!f() { echo password=#{GITHUB_TOKEN}; }; f'", :chdir=>chdir)
    if !status.success?
      job_logger.error "failed to git config credential.helper, error: #{output}"
      return
    end

    output, status = Open3.capture2("git push origin main", :chdir=>chdir)
    if !status.success?
      job_logger.error "failed to git push, error: #{output}"
      return
    end

  end

  def export_repos_to_csv(filename)
    CSV.open(File.join(Rails.root, META_REPO, filename), 'w') do |csv|
      csv << ['repo_url']
      (0...@num_partitions).each do |partition|
        job_logger.info("exporting repo url at partition: #{partition}")
        distinct_values =
          @index.aggregate(
            distinct_values: {
              terms: {
                field: @field,
                size: @batch_size,
                include: {
                  partition: partition,
                  num_partitions: @num_partitions
                },
                order: { _term: :asc }
              }
            }
          ).page(0).aggregations["distinct_values"]["buckets"].each do |row|
          csv << [row['key']] if row['key'] =~ URI::regexp
        end
      end
    end
  rescue => ex
    job_logger.error "failed to export repo urls, error: #{ex.message}"
  end

  def job_logger
    Crono.logger.nil? ? Rails.logger : Crono.logger
  end
end
