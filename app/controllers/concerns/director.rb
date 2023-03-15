module Director
  include Common

  COMMUNITY_CACHE_KEY = 'compass-community-list'

  def director_repo_list(remote_url)
    begin
      Rails.cache.fetch("#{COMMUNITY_CACHE_KEY}-#{__method__}-#{remote_url}-list", expires_in: 15.minutes) do
        encode_url = URI.encode_www_form_component(remote_url)
        response =
          Faraday.get(
            "#{CELERY_SERVER}/api/compass/#{encode_url}/repositories",
            { 'Content-Type' => 'application/json' }
          )
        repo_resp = JSON.parse(response.body)
        repo_resp.inject([]) do |sum, (_, resource)|
          sum + resource.map { |_, list| list }
        end.flatten.uniq
      end
    rescue => ex
      Rails.logger.error("failed to retrive repositories, error: #{ex.message}")
      []
    end
  end
end
