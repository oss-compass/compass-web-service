# frozen_string_literal: true

module Mutations
  class ManageContributorBot < BaseMutation
    include CompassUtils

    field :status, String, null: false

    argument :label, String, required: true, description: 'repo or community label'
    argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
    argument :platform, String, required: true, description: 'platform of the contributor, one of `github/gitee/gitcode`'
    argument :contributor, String, required: true, description: 'name of the contributor'
    argument :is_bot, Boolean, required: false, description: 'true tags the contributor as a robot, false removes the tag', default_value: true

    def resolve(label: nil, level: 'repo', platform: nil, contributor: nil, is_bot: true)
      label = ShortenedLabel.normalize_label(label)

      current_user = context[:current_user]

      # Only the managers of the community/repository and the super
      # administrators are allowed to tag a contributor as a robot manually,
      # `validate_repo_admin!` covers both cases.
      validate_repo_admin!(current_user, label, level)

      if is_bot
        # The tag is stored in the `bots` index which is the source of truth of
        # the data pre-processing pipeline, so the robot is also recognised when
        # the repository is analysed again.
        Bot.tag(
          contributor: contributor,
          platform_type: platform,
          level: level,
          label: label,
          operator: current_user.id
        )
      else
        Bot.untag(contributor, platform)
      end

      # The contributor list is cached, drop the entries of the affected
      # repositories so the tag becomes visible right away.
      indexer, repo_urls, =
        select_idx_repos_by_lablel_and_level(label, level, GiteeContributorEnrich, GithubContributorEnrich, GitcodeContributorEnrich)
      indexer.clear_contributors_cache(repo_urls)

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
