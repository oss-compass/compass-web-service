class OpencheckMetric < BaseMetric

  def self.index_name
    "#{MetricsIndexPrefix}_opencheck"
  end

  def self.settings
    {
      number_of_shards: 1,
      number_of_replicas: 1
    }
  end

  def self.mapping
    {
      properties: {
        id: { type: 'keyword' },
        status: { type: 'text' },
        grimoire_creation_date: { type: 'date' },
        project_url: {
          type: 'text',
          fields: {
            keyword: {
              type: 'keyword',
              ignore_above: 256
            }
          }
        },
        license: {
          properties: {
            license_list: { type: 'text' },
            osi_license_list: { type: 'text' },
            non_osi_licenses: { type: 'text' }
          }

        },
        security: {
          properties: {
            package_name: { type: 'text' },
            package_version: { type: 'text' },
            vulnerabilities: {
              properties: {
                aliases: { type: 'text' },
                published: { type: 'date' },
                severity: { type: 'text' },
                fixed_version: { type: 'text' }
              }
            }
          }
        }
      }
    }
  end


  def self.ensure_index
    return if index_exists?
    self.create_index

  rescue => e
    Rails.logger.error "[OpenSearch] create index error: #{e.class}: #{e.message}"
  end

  def self.save_license(license, security, project_url)
    ensure_index

    document_hash = {
      project_url: project_url,
      grimoire_creation_date: Time.now.utc.iso8601,
      license: license,
      security: security,
      id: SecureRandom.uuid,
      status: "success"
    }

    options = {
      index: index_name
    }
    # self.update_mapping
    document = OpenStruct.new(document_hash)

    index(document, options)
  end

end
