# frozen_string_literal: true
module Openapi
  module Entities

    class GitItem < Grape::Entity
      expose :metadata__updated_on, documentation: { type: 'String', desc: 'metadata__updated_on', example: "2024-12-04T08:46:12+00:00" }
      expose :metadata__timestamp, documentation: { type: 'String', desc: 'metadata__timestamp', example: "2025-01-22T02:49:04.018357+00:00" }
      expose :offset, documentation: { type: 'String', desc: 'offset', example: '' }
      expose :origin, documentation: { type: 'String', desc: 'origin', example: "https://github.com/oss-compass/compass-web-service.git" }
      expose :tag, documentation: { type: 'String', desc: 'tag', example: "https://github.com/oss-compass/compass-web-service.git" }
      expose :uuid, documentation: { type: 'String', desc: 'uuid', example: "f7349874635f4d8f6d12940e7af72013ba83f411" }
      expose :git_uuid, documentation: { type: 'String', desc: 'git_uuid', example: "f7349874635f4d8f6d12940e7af72013ba83f411" }
      expose :message, documentation: { type: 'String', desc: 'message', example: "Bump rexml from 3.3.6 to 3.3.9\n\nBumps [rexml](https://github.com/ruby/rexml) from 3.3.6 to 3.3.9.\n- [Release notes](https://github.com/ruby/rexml/releases)\n- [Changelog](https://github.com/ruby/rexml/blob/master/NEWS.md)\n- [Commits](https://github.com/ruby/rexml/compare/v3.3.6...v3.3.9)\n\n---\nupdated-dependencies:\n- dependency-name: rexml\n  dependency-type: indirect\n...\n\nSigned-off-by: dependabot[bot] <support@github.com>" }
      expose :hash, documentation: { type: 'String', desc: 'hash', example: "fc1b039c547e9023fc7183b119dbb6ed13b337a7" }
      expose :message_analyzed, documentation: { type: 'String', desc: 'message_analyzed', example: "Bump rexml from 3.3.6 to 3.3.9\n\nBumps [rexml](https://github.com/ruby/rexml) from 3.3.6 to 3.3.9.\n- [Release notes](https://github.com/ruby/rexml/releases)\n- [Changelog](https://github.com/ruby/rexml/blob/master/NEWS.md)\n- [Commits](https://github.com/ruby/rexml/compare/v3.3.6...v3.3.9)\n\n---\nupdated-dependencies:\n- dependency-name: rexml\n  dependency-type: indirect\n...\n\nSigned-off-by: dependabot[bot] <support@github.com>" }
      expose :commit_tags, documentation: { type: 'String', desc: 'commit_tags', example: [], is_array: true }
      expose :hash_short, documentation: { type: 'String', desc: 'hash_short', example: "fc1b03" }
      expose :author_date, documentation: { type: 'String', desc: 'author_date', example: "2024-10-28T18:51:57" }
      expose :commit_date, documentation: { type: 'String', desc: 'commit_date', example: "2024-12-04T16:46:12" }
      expose :author_date_weekday, documentation: { type: 'Integer', desc: 'author_date_weekday', example: 1 }
      expose :author_date_hour, documentation: { type: 'Integer', desc: 'author_date_hour', example: 18 }
      expose :commit_date_weekday, documentation: { type: 'Integer', desc: 'commit_date_weekday', example: 3 }
      expose :commit_date_hour, documentation: { type: 'Integer', desc: 'commit_date_hour', example: 16 }
      expose :utc_author, documentation: { type: 'String', desc: 'utc_author', example: "2024-10-28T18:51:57" }
      expose :utc_commit, documentation: { type: 'String', desc: 'utc_commit', example: "2024-12-04T08:46:12" }
      expose :utc_author_date_weekday, documentation: { type: 'Integer', desc: 'utc_author_date_weekday', example: 1 }
      expose :utc_author_date_hour, documentation: { type: 'Integer', desc: 'utc_author_date_hour', example: 18 }
      expose :utc_commit_date_weekday, documentation: { type: 'Integer', desc: 'utc_commit_date_weekday', example: 3 }
      expose :utc_commit_date_hour, documentation: { type: 'Integer', desc: 'utc_commit_date_hour', example: 8 }
      expose :tz, documentation: { type: 'Integer', desc: 'tz', example: 0 }
      expose :branches, documentation: { type: 'String', desc: 'branches', example: [], is_array: true }
      expose :time_to_commit_hours, documentation: { type: 'Float', desc: 'time_to_commit_hours', example: 10.1 }
      expose :repo_name, documentation: { type: 'String', desc: 'repo_name', example: "https://github.com/oss-compass/compass-web-service.git" }
      expose :files, documentation: { type: 'Integer', desc: 'files', example: 1 }
      expose :lines_added, documentation: { type: 'Integer', desc: 'lines_added', example: 1 }
      expose :lines_removed, documentation: { type: 'Integer', desc: 'lines_removed', example: 3 }
      expose :lines_changed, documentation: { type: 'Integer', desc: 'lines_changed', example: 4 }
      expose :author_name, documentation: { type: 'String', desc: 'author_name', example: "dependabot[bot]" }
      expose :author_domain, documentation: { type: 'String', desc: 'author_domain', example: "users.noreply.github.com" }
      expose :committer_name, documentation: { type: 'String', desc: 'committer_name', example: "edmondfrank" }
      expose :committer_domain, documentation: { type: 'String', desc: 'committer_domain', example: "hotmail.com" }
      expose :title, documentation: { type: 'String', desc: 'title', example: "Bump rexml from 3.3.6 to 3.3.9" }
      expose :github_repo, documentation: { type: 'String', desc: 'github_repo', example: "oss-compass/compass-web-service" }
      expose :url_id, documentation: { type: 'String', desc: 'url_id', example: "oss-compass/compass-web-service/commit/fc1b039c547e9023fc7183b119dbb6ed13b337a7" }
      expose :git_author_domain, documentation: { type: 'String', desc: 'git_author_domain', example: "users.noreply.github.com" }
      expose :grimoire_creation_date, documentation: { type: 'String', desc: 'grimoire_creation_date', example: "2024-10-28T18:51:57+00:00" }
      expose :is_git_commit, documentation: { type: 'Integer', desc: 'is_git_commit', example: 1 }
      expose :Author_id, documentation: { type: 'String', desc: 'Author_id', example: "fdccf817a8aeb0256403b9083b9d7af84772692f" }
      expose :Author_uuid, documentation: { type: 'String', desc: 'Author_uuid', example: "fdccf817a8aeb0256403b9083b9d7af84772692f" }
      expose :Author_name, documentation: { type: 'String', desc: 'Author_name', example: "dependabot[bot]" }
      expose :Author_user_name, documentation: { type: 'String', desc: 'Author_user_name', example: "Unknown" }
      expose :Author_domain, documentation: { type: 'String', desc: 'Author_domain', example: "users.noreply.github.com" }
      expose :Author_gender, documentation: { type: 'String', desc: 'Author_gender', example: "Unknown" }
      expose :Author_gender_acc, documentation: { type: 'String', desc: 'Author_gender_acc', example: '' }
      expose :Author_org_name, documentation: { type: 'String', desc: 'Author_org_name', example: "Unknown" }
      expose :Author_bot, documentation: { type: 'Boolean', desc: 'Author_bot', example: false }
      expose :Author_multi_org_names, documentation: { type: 'String', desc: 'Author_multi_org_names', example: ["Unknown"], is_array: true }
      expose :Commit_id, documentation: { type: 'String', desc: 'Commit_id', example: "dafe421afde91bdc27b366843ee35f56fe58753e" }
      expose :Commit_uuid, documentation: { type: 'String', desc: 'Commit_uuid', example: "dafe421afde91bdc27b366843ee35f56fe58753e" }
      expose :Commit_name, documentation: { type: 'String', desc: 'Commit_name', example: "edmondfrank" }
      expose :Commit_user_name, documentation: { type: 'String', desc: 'Commit_user_name', example: "Unknown" }
      expose :Commit_domain, documentation: { type: 'String', desc: 'Commit_domain', example: "hotmail.com" }
      expose :Commit_gender, documentation: { type: 'String', desc: 'Commit_gender', example: "Unknown" }
      expose :Commit_gender_acc, documentation: { type: 'String', desc: 'Commit_gender_acc', example: '' }
      expose :Commit_org_name, documentation: { type: 'String', desc: 'Commit_org_name', example: "Unknown" }
      expose :Commit_bot, documentation: { type: 'Boolean', desc: 'Commit_bot', example: false }
      expose :Commit_multi_org_names, documentation: { type: 'String', desc: 'Commit_multi_org_names', example: ["Unknown"], is_array: true }
      expose :author_id, documentation: { type: 'String', desc: 'author_id', example: "fdccf817a8aeb0256403b9083b9d7af84772692f" }
      expose :author_uuid, documentation: { type: 'String', desc: 'author_uuid', example: "fdccf817a8aeb0256403b9083b9d7af84772692f" }
      expose :author_user_name, documentation: { type: 'String', desc: 'author_user_name', example: "Unknown" }
      expose :author_gender, documentation: { type: 'String', desc: 'author_gender', example: "Unknown" }
      expose :author_gender_acc, documentation: { type: 'String', desc: 'author_gender_acc', example: '' }
      expose :author_org_name, documentation: { type: 'String', desc: 'author_org_name', example: "Unknown" }
      expose :author_bot, documentation: { type: 'Boolean', desc: 'author_bot', example: false }
      expose :author_multi_org_names, documentation: { type: 'String', desc: 'author_multi_org_names', example: ["Unknown"], is_array: true }
      expose :project, documentation: { type: 'String', desc: 'project', example: "Github-Seraphine" }
      expose :project_1, documentation: { type: 'String', desc: 'project_1', example: "Github-Seraphine" }
      expose :repository_labels, documentation: { type: 'String', desc: 'repository_labels', example: [], is_array: true }
      expose :metadata__filter_raw, documentation: { type: 'String', desc: 'metadata__filter_raw', example: '' }
      expose :acked_by_multi_bots, documentation: { type: 'String', desc: 'acked_by_multi_bots', example: [], is_array: true }
      expose :acked_by_multi_domains, documentation: { type: 'String', desc: 'acked_by_multi_domains', example: [], is_array: true }
      expose :acked_by_multi_names, documentation: { type: 'String', desc: 'acked_by_multi_names', example: [], is_array: true }
      expose :acked_by_multi_org_names, documentation: { type: 'String', desc: 'acked_by_multi_org_names', example: [], is_array: true }
      expose :acked_by_multi_uuids, documentation: { type: 'String', desc: 'acked_by_multi_uuids', example: [], is_array: true }
      expose :co_developed_by_multi_bots, documentation: { type: 'String', desc: 'co_developed_by_multi_bots', example: [], is_array: true }
      expose :co_developed_by_multi_domains, documentation: { type: 'String', desc: 'co_developed_by_multi_domains', example: [], is_array: true }
      expose :co_developed_by_multi_names, documentation: { type: 'String', desc: 'co_developed_by_multi_names', example: [], is_array: true }
      expose :co_developed_by_multi_org_names, documentation: { type: 'String', desc: 'co_developed_by_multi_org_names', example: [], is_array: true }
      expose :co_developed_by_multi_uuids, documentation: { type: 'String', desc: 'co_developed_by_multi_uuids', example: [], is_array: true }
      expose :reported_by_multi_bots, documentation: { type: 'String', desc: 'reported_by_multi_bots', example: [], is_array: true }
      expose :reported_by_multi_domains, documentation: { type: 'String', desc: 'reported_by_multi_domains', example: [], is_array: true }
      expose :reported_by_multi_names, documentation: { type: 'String', desc: 'reported_by_multi_names', example: [], is_array: true }
      expose :reported_by_multi_org_names, documentation: { type: 'String', desc: 'reported_by_multi_org_names', example: [], is_array: true }
      expose :reported_by_multi_uuids, documentation: { type: 'String', desc: 'reported_by_multi_uuids', example: [], is_array: true }
      expose :reviewed_by_multi_bots, documentation: { type: 'String', desc: 'reviewed_by_multi_bots', example: [], is_array: true }
      expose :reviewed_by_multi_domains, documentation: { type: 'String', desc: 'reviewed_by_multi_domains', example: [], is_array: true }
      expose :reviewed_by_multi_names, documentation: { type: 'String', desc: 'reviewed_by_multi_names', example: [], is_array: true }
      expose :reviewed_by_multi_org_names, documentation: { type: 'String', desc: 'reviewed_by_multi_org_names', example: [], is_array: true }
      expose :reviewed_by_multi_uuids, documentation: { type: 'String', desc: 'reviewed_by_multi_uuids', example: [], is_array: true }
      expose :signed_off_by_multi_bots, documentation: { type: 'String', desc: 'signed_off_by_multi_bots', example: [false], is_array: true }
      expose :signed_off_by_multi_domains, documentation: { type: 'String', desc: 'signed_off_by_multi_domains', example: ["github.com"], is_array: true }
      expose :signed_off_by_multi_names, documentation: { type: 'String', desc: 'signed_off_by_multi_names', example: ["dependabot[bot]"], is_array: true }
      expose :signed_off_by_multi_org_names, documentation: { type: 'String', desc: 'signed_off_by_multi_org_names', example: ["Unknown"], is_array: true }
      expose :signed_off_by_multi_uuids, documentation: { type: 'String', desc: 'signed_off_by_multi_uuids', example: ["7eb115b07f52d0370010dbf9053838b5a810fdb7"], is_array: true }
      expose :suggested_by_multi_bots, documentation: { type: 'String', desc: 'suggested_by_multi_bots', example: [], is_array: true }
      expose :suggested_by_multi_domains, documentation: { type: 'String', desc: 'suggested_by_multi_domains', example: [], is_array: true }
      expose :suggested_by_multi_names, documentation: { type: 'String', desc: 'suggested_by_multi_names', example: [], is_array: true }
      expose :suggested_by_multi_org_names, documentation: { type: 'String', desc: 'suggested_by_multi_org_names', example: [], is_array: true }
      expose :suggested_by_multi_uuids, documentation: { type: 'String', desc: 'suggested_by_multi_uuids', example: [], is_array: true }
      expose :tested_by_multi_bots, documentation: { type: 'String', desc: 'tested_by_multi_bots', example: [], is_array: true }
      expose :tested_by_multi_domains, documentation: { type: 'String', desc: 'tested_by_multi_domains', example: [], is_array: true }
      expose :tested_by_multi_names, documentation: { type: 'String', desc: 'tested_by_multi_names', example: [], is_array: true }
      expose :tested_by_multi_org_names, documentation: { type: 'String', desc: 'tested_by_multi_org_names', example: [], is_array: true }
      expose :tested_by_multi_uuids, documentation: { type: 'String', desc: 'tested_by_multi_uuids', example: [], is_array: true }
      expose :non_authored_acked_by_multi_bots, documentation: { type: 'String', desc: 'non_authored_acked_by_multi_bots', example: [], is_array: true }
      expose :non_authored_acked_by_multi_domains, documentation: { type: 'String', desc: 'non_authored_acked_by_multi_domains', example: [], is_array: true }
      expose :non_authored_acked_by_multi_names, documentation: { type: 'String', desc: 'non_authored_acked_by_multi_names', example: [], is_array: true }
      expose :non_authored_acked_by_multi_org_names, documentation: { type: 'String', desc: 'non_authored_acked_by_multi_org_names', example: [], is_array: true }
      expose :non_authored_acked_by_multi_uuids, documentation: { type: 'String', desc: 'non_authored_acked_by_multi_uuids', example: [], is_array: true }
      expose :non_authored_co_developed_by_multi_bots, documentation: { type: 'String', desc: 'non_authored_co_developed_by_multi_bots', example: [], is_array: true }
      expose :non_authored_co_developed_by_multi_domains, documentation: { type: 'String', desc: 'non_authored_co_developed_by_multi_domains', example: [], is_array: true }
      expose :non_authored_co_developed_by_multi_names, documentation: { type: 'String', desc: 'non_authored_co_developed_by_multi_names', example: [], is_array: true }
      expose :non_authored_co_developed_by_multi_org_names, documentation: { type: 'String', desc: 'non_authored_co_developed_by_multi_org_names', example: [], is_array: true }
      expose :non_authored_co_developed_by_multi_uuids, documentation: { type: 'String', desc: 'non_authored_co_developed_by_multi_uuids', example: [], is_array: true }
      expose :non_authored_reported_by_multi_bots, documentation: { type: 'String', desc: 'non_authored_reported_by_multi_bots', example: [], is_array: true }
      expose :non_authored_reported_by_multi_domains, documentation: { type: 'String', desc: 'non_authored_reported_by_multi_domains', example: [], is_array: true }
      expose :non_authored_reported_by_multi_names, documentation: { type: 'String', desc: 'non_authored_reported_by_multi_names', example: [], is_array: true }
      expose :non_authored_reported_by_multi_org_names, documentation: { type: 'String', desc: 'non_authored_reported_by_multi_org_names', example: [], is_array: true }
      expose :non_authored_reported_by_multi_uuids, documentation: { type: 'String', desc: 'non_authored_reported_by_multi_uuids', example: [], is_array: true }
      expose :non_authored_reviewed_by_multi_bots, documentation: { type: 'String', desc: 'non_authored_reviewed_by_multi_bots', example: [], is_array: true }
      expose :non_authored_reviewed_by_multi_domains, documentation: { type: 'String', desc: 'non_authored_reviewed_by_multi_domains', example: [], is_array: true }
      expose :non_authored_reviewed_by_multi_names, documentation: { type: 'String', desc: 'non_authored_reviewed_by_multi_names', example: [], is_array: true }
      expose :non_authored_reviewed_by_multi_org_names, documentation: { type: 'String', desc: 'non_authored_reviewed_by_multi_org_names', example: [], is_array: true }
      expose :non_authored_reviewed_by_multi_uuids, documentation: { type: 'String', desc: 'non_authored_reviewed_by_multi_uuids', example: [], is_array: true }
      expose :non_authored_signed_off_by_multi_bots, documentation: { type: 'String', desc: 'non_authored_signed_off_by_multi_bots', example: [false], is_array: true }
      expose :non_authored_signed_off_by_multi_domains, documentation: { type: 'String', desc: 'non_authored_signed_off_by_multi_domains', example: ["github.com"], is_array: true }
      expose :non_authored_signed_off_by_multi_names, documentation: { type: 'String', desc: 'non_authored_signed_off_by_multi_names', example: ["dependabot[bot]"], is_array: true }
      expose :non_authored_signed_off_by_multi_org_names, documentation: { type: 'String', desc: 'non_authored_signed_off_by_multi_org_names', example: ["Unknown"], is_array: true }
      expose :non_authored_signed_off_by_multi_uuids, documentation: { type: 'String', desc: 'non_authored_signed_off_by_multi_uuids', example: ["7eb115b07f52d0370010dbf9053838b5a810fdb7"], is_array: true }
      expose :non_authored_suggested_by_multi_bots, documentation: { type: 'String', desc: 'non_authored_suggested_by_multi_bots', example: [], is_array: true }
      expose :non_authored_suggested_by_multi_domains, documentation: { type: 'String', desc: 'non_authored_suggested_by_multi_domains', example: [], is_array: true }
      expose :non_authored_suggested_by_multi_names, documentation: { type: 'String', desc: 'non_authored_suggested_by_multi_names', example: [], is_array: true }
      expose :non_authored_suggested_by_multi_org_names, documentation: { type: 'String', desc: 'non_authored_suggested_by_multi_org_names', example: [], is_array: true }
      expose :non_authored_suggested_by_multi_uuids, documentation: { type: 'String', desc: 'non_authored_suggested_by_multi_uuids', example: [], is_array: true }
      expose :non_authored_tested_by_multi_bots, documentation: { type: 'String', desc: 'non_authored_tested_by_multi_bots', example: [], is_array: true }
      expose :non_authored_tested_by_multi_domains, documentation: { type: 'String', desc: 'non_authored_tested_by_multi_domains', example: [], is_array: true }
      expose :non_authored_tested_by_multi_names, documentation: { type: 'String', desc: 'non_authored_tested_by_multi_names', example: [], is_array: true }
      expose :non_authored_tested_by_multi_org_names, documentation: { type: 'String', desc: 'non_authored_tested_by_multi_org_names', example: [], is_array: true }
      expose :non_authored_tested_by_multi_uuids, documentation: { type: 'String', desc: 'non_authored_tested_by_multi_uuids', example: [], is_array: true }
      expose :metadata__gelk_version, documentation: { type: 'String', desc: 'metadata__gelk_version', example: "0.103.0-rc.2" }
      expose :metadata__gelk_backend_name, documentation: { type: 'String', desc: 'metadata__gelk_backend_name', example: "GitEnrich" }
      expose :metadata__enriched_on, documentation: { type: 'String', desc: 'metadata__enriched_on', example: "2025-01-22T02:50:51.727591+00:00" }

    end

    class GitResponse < Grape::Entity
      expose :count, documentation: { type: 'int', desc: 'Total Count/总数', example: 100 }
      expose :total_page, documentation: { type: 'int', desc: 'Total Pages/总页数', example: 2 }
      expose :page, documentation: { type: 'int', desc: 'Current Page/当前页', example: 1 }
      expose :items, using: Entities::GitItem, documentation: { type: 'Entities::GitItem', desc: 'response',
                                                                param_type: 'body', is_array: true }
    end

  end
end
