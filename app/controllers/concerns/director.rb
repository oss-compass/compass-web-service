module Director
  include Common

  COMMUNITY_CACHE_KEY = 'compass-community-list'
  GOVERNANCE_TYPE = 'governance'
  ARTIFACT_TYPE = 'software-artifact'
  UNKOWNN_TYPE = 'unknown'

  def director_repo_list(remote_url)
    begin
      Rails.cache.fetch("#{COMMUNITY_CACHE_KEY}:#{__method__}:#{remote_url}", expires_in: 15.minutes) do
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

  def director_repo_list_with_type(remote_url)
    begin
      Rails.cache.fetch("#{COMMUNITY_CACHE_KEY}-#{__method__}-#{remote_url}-list-with-type", expires_in: 15.minutes) do
        encode_url = URI.encode_www_form_component(remote_url)
        response =
          Faraday.get(
            "#{CELERY_SERVER}/api/compass/#{encode_url}/repositories",
            { 'Content-Type' => 'application/json' }
          )
        repo_resp = JSON.parse(response.body)
        repo_resp.inject([]) do |sum, (_, resource)|
          sum + resource.map do |type, list|
            type = detect_type(type)
            list.map { |repo|  { repo: repo, type: type }}
          end
        end.flatten.uniq
      end
    rescue => ex
      Rails.logger.error("failed to retrive repositories, error: #{ex.message}")
      []
    end
  end


  private

  def detect_type(type_str)
    return ARTIFACT_TYPE if type_str.include?(ARTIFACT_TYPE)
    return GOVERNANCE_TYPE if type_str.include?(GOVERNANCE_TYPE)
    return UNKOWNN_TYPE
  end
end
