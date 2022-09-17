module Common
  HOST = ENV.fetch('DEFAULT_HOST') { 'http://localhost:3000' }
  PROXY = ENV.fetch('PROXY') { 'http://localhost:10807' }
  HOOK_PASS = ENV.fetch('HOOK_PASS') { 'password' }
  SINGLE_DIR = 'single-projects'
  ORG_DIR = 'organizations'

  def extract_domain(url)
    Addressable::URI.parse(url)&.normalized_host
  end
end
