namespace :db do
  desc "Auto sync refs between communities and repos by `compass-projects-information`"
  task sync_refs_between_communities_and_repos: :environment do
    include Common
    directory = 'communities'
    chdir = "#{Rails.root + META_REPO}"
    Dir.glob("#{Rails.root + META_REPO + directory}/*.yml").each do |file|
      puts "begin to refresh #{file}"
      begin
        yaml =
          file
            .then { File.read _1 }
            .then { YAML.load _1 }
        community_name = yaml['community_name']

        software_artifact_repositories =
          yaml.dig('resource_types', 'software-artifact-repositories', 'repo_urls') ||
          yaml.dig('resource_types', 'software-artifact-resources', 'repo_urls') ||
          yaml.dig('resource_types', 'software-artifact-projects', 'repo_urls') || []

        governance_repositories =
          yaml.dig('resource_types', 'governance-repositories', 'repo_urls') ||
          yaml.dig('resource_types', 'governance-resources', 'repo_urls') ||
          yaml.dig('resource_types', 'governance-projects', 'repo_urls') || []

        #puts software_artifact_repositories, governance_repositories

        real_count = (software_artifact_repositories + governance_repositories).uniq.length

        subject = Subject.find_or_initialize_by(label: community_name)
        subject.level = 'community'
        subject.status ||= Subject::PENDING
        subject.count ||= 0
        subject.status_updated_at ||= Time.current
        subject.save!

        if subject.count != real_count

          Subject.sync_subject_repos_refs(subject, new_software_repos: software_artifact_repositories, new_governance_repos: governance_repositories)

          subject.update!(count: real_count)
          puts "refresh #{file} successfully"
        else
          puts "#{file} no changes"
        end
      rescue => ex
        puts "failed to refresh #{file}, error: #{ex.message}"
      end
    end
  end
end
