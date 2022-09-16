module Common
  HOST = ENV.fetch('DEFAULT_HOST')
  HOOK_PASS = ENV.fetch('HOOK_PASS') { 'password' }
  SINGLE_DIR = 'single-projects'
  ORG_DIR = 'organizations'
end
