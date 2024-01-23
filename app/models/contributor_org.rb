# frozen_string_literal: true

class ContributorOrg < BaseIndex
  URL = 'URL'
  RepoAdmin = 'Repo Admin'
  SystemAdmin = 'System Admin'
  UserIndividual = 'User Individual'
  GobalScopes = [UserIndividual]

  def self.index_name
    'contributor_org'
  end
end
