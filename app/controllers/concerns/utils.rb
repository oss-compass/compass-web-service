module Utils
  def redirect_url(error: nil, default_url: nil, skip_cookies: false)
    default_host = Addressable::URI.parse(ENV['DEFAULT_HOST'])
    url = (defined?(cookies) && cookies['auth.callback-url'].presence) || default_url
    url = default_url if skip_cookies
    uri = Addressable::URI.parse(url)
    uri.scheme = default_host.scheme
    uri.host = default_host.host
    if error.present?
      uri.query_values = uri.query_values.to_h.merge({ error: error, ts: (Time.now.to_f * 1000).to_i })
    end
    uri.to_s
  end
end
