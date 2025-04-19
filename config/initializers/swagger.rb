host = ENV.fetch('DEFAULT_HOST') { 'localhost' }
port = ENV.fetch('DEFAULT_PORT') { '7000' }
GrapeSwaggerRails.options.app_url = "#{host}:#{port}/api/v2"
GrapeSwaggerRails.options.url     = '/docs'
