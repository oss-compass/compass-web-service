# frozen_string_literal: true
module ContributorContributorEnrich
  extend ActiveSupport::Concern


  class_methods do
    def list(contributor, begin_date, end_date, page: 1, per: 1)
      self.must(match_phrase: { 'from_contributor.keyword': contributor })
          .range('created_at', gte: begin_date, lte: end_date)
          .page(page)
          .per(per)
          .execute
          .raw_response
    end
  end
end
