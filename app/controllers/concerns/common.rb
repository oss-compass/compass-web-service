module Common
  ORG_DIR = 'organizations'
  SINGLE_DIR = 'single-projects'
  HOOK_PASS = ENV.fetch('HOOK_PASS') { 'password' }
  PROXY = ENV.fetch('PROXY') { 'http://localhost:10807' }
  HOST = ENV.fetch('DEFAULT_HOST') { 'http://localhost:3000' }
  CELERY_SERVER = ENV.fetch('CELERY_SERVER') { 'http://localhost:8000' }
  SUPPORT_DOMAINS = ['gitee.com', 'github.com', 'raw.githubusercontent.com']
  SUPPORT_DOMAIN_NAMES = ['gitee', 'github']

  def extract_domain(url)
    Addressable::URI.parse(url)&.normalized_host
  end
end
