# frozen_string_literal: true

class ContributorOrg < BaseIndex
  URL = 'URL'
  RepoAdmin = 'Repo Admin'
  UserIndividual = 'User Individual'

  def self.index_name
    'contributor_org'
  end
end
