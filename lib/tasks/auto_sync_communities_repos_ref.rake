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
          yaml.dig('resource_types', 'software-artifact-projects', 'repo_urls') || []

        governance_repositories =
          yaml.dig('resource_types', 'governance-repositories', 'repo_urls') ||
          yaml.dig('resource_types', 'governance-projects', 'repo_urls') || []

        real_count = (software_artifact_repositories + governance_repositories).uniq.length

        subject = Subject.find_or_initialize_by(label: community_name)
        subject.level = 'community'
        subject.status ||= Subject::PENDING
        subject.count ||= 0
        subject.status_updated_at ||= Time.current
        subject.save!

        append_child = -> (parent, label, type) do
          child = Subject.find_or_initialize_by(label: label)
          child.level ||= 'repo'
          child.status ||= Subject::PENDING
          child.count = 1
          child.status_updated_at ||= Time.current
          child.save!
          SubjectRef.create!(parent: parent, child: child, sub_type: type)
        end

        remove_child = -> (parent, label, type) do
          SubjectRef.where(parent: parent, child: label, sub_type: type).destroy_all
        end

        if subject.count != real_count
          stable_software_artifact_repositories = subject.software_repos.pluck('label')

          (software_artifact_repositories - stable_software_artifact_repositories).each do |label|
            append_child.(subject, label, SubjectRef::Software)
          end

          (stable_software_artifact_repositories - software_artifact_repositories).each do |label|
            remove_child.(subject, label, SubjectRef::Software)
          end

          stable_governance_repositories = subject.governance_repos.pluck('label')

          (governance_repositories - stable_governance_repositories).each do |label|
            append_child.(subject, label, SubjectRef::Governance)
          end

          (stable_governance_repositories - governance_repositories).each do |label|
            remove_child.(subject, label, SubjectRef::Governance)
          end

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
