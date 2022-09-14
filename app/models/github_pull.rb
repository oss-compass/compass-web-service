# frozen_string_literal: true

class GithubPull < GithubBase
  def self.index_name
    'github-pull_raw'
  end
end
