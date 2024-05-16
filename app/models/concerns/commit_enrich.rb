# frozen_string_literal: true

module CommitEnrich
  extend ActiveSupport::Concern
  class_methods do

    MAX_PER_PAGE = 10000

    def base_commit_list_by_repo_urls(
      repo_urls, begin_date, end_date, branch,
      target: 'tag', filter: :grimoire_creation_date, sort: :grimoire_creation_date, direction: :desc,
      filter_opts: [], sort_opts: []
    )
      base =
        self
          .must(terms: { target => repo_urls.map { |element| element + ".git" } })
          .must(match_phrase: { branches: "'#{branch}'" })
          .must(wildcard: { author_email: { value: "*@*" } })
          .must(wildcard: { committer_email: { value: "*@*" } })
          .must(range: { lines_changed: { gt: 0 } })
          .must_not(terms: { author_email: ["mamingshuai@huawei.com", "wenjun1@huawei.com"] })
          .must_not(terms: { committer_email: ["mamingshuai@huawei.com", "wenjun1@huawei.com"] })
          .must_not(wildcard: { author_email: { value: "*noreply*" } })
          .must_not(wildcard: { committer_email: { value: "*noreply*" } })
          .must_not(wildcard: { message: { value: "*Merge pull request*" } })
          .range(filter, gte: begin_date, lte: end_date)

      if filter_opts.present?
        filter_opts.each do |filter_opt|
          if filter_opt.type == "commit_hash"
            base = base.where("hash" => filter_opt.values)
          elsif filter_opt.type == "repo_name"
            base = base.where(filter_opt.type => filter_opt.values.map { |element| element + ".git" })
          elsif filter_opt.type == "org_name"
            if filter_opt.values.include?("unknown")
              domain_list = Organization.domain_list()
              base = base.must_not(terms: { author_domain: domain_list })
            else
              domain_list = Organization.domain_list_by_org_name_list(filter_opt.values)
              base = base.where(author_domain: domain_list)
            end
          else
            base = base.where(filter_opt.type => filter_opt.values)
          end
        end
      end

      if sort_opts.present?
        sort_opts.each do |sort_opt|
          if sort_opt.type == "commit_hash"
            base = base.sort(hash: sort_opt.direction)
          else
            base = base.sort(sort_opt.type => sort_opt.direction)
          end
        end
      else
        base = base.sort(sort => direction)
      end

      base

    end

    def fetch_commit_page_by_repo_urls(
      repo_urls, begin_date, end_date, branch,
      target: 'tag', filter: :grimoire_creation_date, sort: :grimoire_creation_date, direction: :desc,
      per: 1, page: 1, filter_opts: [], sort_opts: []
    )
      base_commit_list_by_repo_urls(
        repo_urls, begin_date, end_date, branch,
        target: target, filter: filter, sort: sort, direction: direction,
        filter_opts: filter_opts, sort_opts: sort_opts
      )
        .page(page)
        .per(per)
        .execute
        .raw_response
    end

    def commit_count_by_repo_urls(
      repo_urls, begin_date, end_date, branch,
      target: 'tag', filter: :grimoire_creation_date, filter_opts: []
    )

      base_commit_list_by_repo_urls(
        repo_urls, begin_date, end_date, branch,
        target: target, filter: filter, filter_opts: filter_opts
      )
        .total_entries
    end

    def fetch_commit_contributor_list_by_repo_urls(repo_urls, begin_date, end_date, branch, per, target: 'tag')
      base_commit_list_by_repo_urls(repo_urls, begin_date, end_date, branch, target: target)
        .aggregate(
          group_by_name: {
            terms: { field: "author_email", size: per },
            aggs: {
              lines_changed: { sum: { field: "lines_changed" } },
              lines_added: { sum: { field: "lines_added" } },
              lines_removed: { sum: { field: "lines_removed" } },
              author_domain: { top_hits: { _source: ["author_domain"], size: 1 } },
              sort_bucket: { bucket_sort: { sort: [{ lines_changed: { order: "desc" } }] } }
            }
          })
        .per(0)
        .execute
        .raw_response
    end

    def fetch_commit_organization_list_by_repo_urls(repo_urls, begin_date, end_date, branch, target: 'tag')
      base_commit_list_by_repo_urls(repo_urls, begin_date, end_date, branch, target: target)
        .aggregate(
          group_by_name: {
            terms: { field: "author_domain", size: MAX_PER_PAGE },
            aggs: {
              lines_changed: { sum: { field: "lines_changed" } },
              lines_added: { sum: { field: "lines_added" } },
              lines_removed: { sum: { field: "lines_removed" } },
              sort_bucket: { bucket_sort: { sort: [{ lines_changed: { order: "desc" } }] } }
            }
          })
        .per(0)
        .execute
        .raw_response
    end

    def merge_commit_organization(source, target)
      base = source.merge(target)
      base[:lines_added] = source[:lines_added].to_i + target[:lines_added].to_i
      base[:lines_removed] = source[:lines_removed].to_i + target[:lines_removed].to_i
      base[:lines_changed] = source[:lines_changed].to_i + target[:lines_changed].to_i
      base[:lines_changed_ratio] = base[:total_lines_changed] == 0 ? 0 : (base[:lines_changed] / base[:total_lines_changed]).round(4)
      base
    end

    def lines_changed_count_by_repo_urls(repo_urls, begin_date, end_date, branch, target: 'tag')
      base_commit_list_by_repo_urls(repo_urls, begin_date, end_date, branch, target: target)
        .aggregate(total_lines_changed: { sum: { field: "lines_changed" } })
        .per(0)
        .execute
        .raw_response
    end

    def fetch_commit_repo_list(repo_urls, begin_date, end_date, branch, target: 'tag')
      base_commit_list_by_repo_urls(repo_urls, begin_date, end_date, branch, target: target)
        .aggregate(
          group_by_name: {
            terms: { field: "tag", size: MAX_PER_PAGE, order: { _key: "asc" } },
            aggs: {
              lines_changed: { sum: { field: "lines_changed" } },
              lines_added: { sum: { field: "lines_added" } },
              lines_removed: { sum: { field: "lines_removed" } }
            }
          })
        .per(0)
        .execute
        .raw_response
    end

  end
end
