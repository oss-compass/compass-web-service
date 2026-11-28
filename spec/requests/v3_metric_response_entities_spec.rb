# frozen_string_literal: true

require 'rails_helper'

# Contract spec for the V3 metric endpoints that read data through
# `Openapi::SharedParams::CustomMetricSearch#fetch_metric_data_v2`.
#
# That helper builds every item with `source.slice(*target_fields)`, so an item
# only carries the shared base fields plus the exact metric fields requested by
# the route. When a response entity exposes a different attribute name (for
# example `contributor_count` while the route requested
# `total_active_contributors`), the real value is dropped and the attribute is
# serialised as nil, which the project analysis page then renders as 0.
#
# Routes and entities live in separate files, so nothing at runtime keeps the
# two names aligned. This spec reads both sources and fails as soon as a route
# asks for a field that its response entity does not expose.
RSpec.describe 'V3 metric response entities', type: :request do
  # Attributes every item entity may expose even though no route has to request
  # them explicitly.
  def base_item_fields
    %w[uuid level label type model_name period grimoire_creation_date metadata__enriched_on]
  end

  def v3_api_path
    Rails.root.join('app/api/openapi/v3').to_s
  end

  def entities_path
    Rails.root.join('app/api/openapi/entities').to_s
  end

  # Entity class name => the source lines that define it.
  def entity_sources
    @entity_sources ||= Dir["#{entities_path}/**/*.rb"].sort.each_with_object({}) do |path, memo|
      entity_name = nil
      File.readlines(path).each do |line|
        entity_name = line[/class\s+(\w+)\s*<\s*Grape::Entity/, 1] || entity_name
        (memo[entity_name] ||= []) << line if entity_name
      end
    end
  end

  def exposed_fields(entity_name)
    Array(entity_sources[entity_name]).filter_map { |line| line[/^\s*expose\s+:(\w+)/, 1] }
  end

  def exposed_metric_fields(entity_name)
    exposed_fields(entity_name) - base_item_fields
  end

  # The items of a response entity are rendered with the matching item entity.
  def item_entity_name(response_entity)
    line = Array(entity_sources[response_entity]).find { |candidate| candidate =~ /using:\s*Entities::\w+/ }
    line && line[/using:\s*Entities::(\w+)/, 1]
  end

  def metric_endpoints
    @metric_endpoints ||= Dir["#{v3_api_path}/**/*.rb"].sort.flat_map { |path| request_definitions(path) }
  end

  def request_definitions(path)
    lines = File.readlines(path).reject { |line| line.lstrip.start_with?('#') }
    indexes = lines.each_index.select { |index| metric_route?(lines, index) }
    indexes.map { |index| request_definition(path, lines, index) }
  end

  def metric_route?(lines, index)
    lines[index] =~ /^\s*post\s+:\w+\s+do\b/ && route_body(lines, index).include?('fetch_metric_data_v2(')
  end

  def route_body(lines, index)
    body = []
    (index + 1...lines.size).each do |line_index|
      break if lines[line_index] =~ /^\s{10,}end\b/

      body << lines[line_index]
    end
    body.join
  end

  def request_definition(path, lines, index)
    {
      path: path,
      endpoint: lines[index][/post\s+:(\w+)/, 1],
      entity: success_entity(lines, index),
      fields: requested_fields(route_body(lines, index))
    }
  end

  # The success documentation declaring the response entity of a route.
  def success_entity(lines, index)
    preceding = lines[0...index].reverse.take_while { |line| line !~ /^\s*post\s+:/ }
    line = preceding.find { |candidate| candidate =~ /Openapi::Entities::\w+/ }
    line && line[/Openapi::Entities::(\w+)/, 1]
  end

  # Fields handed to fetch_metric_data_v2, resolving local %w[] variables.
  def requested_fields(body)
    arguments = body[/fetch_metric_data_v2\(\s*\w+\s*,\s*([^)]*)\)/, 1]
    return [] unless arguments

    name = arguments.strip
    fields = body[/^\s*#{Regexp.escape(name)}\s*=\s*%w\[([^\]]*)\]/, 1]
    (fields || name).scan(/\w+/)
  end

  # Routes asking for a field that their response entity never exposes. The
  # value cannot reach the response, which is how a contributor count ends up
  # being reported as 0.
  def dropped_metric_fields
    metric_endpoints.flat_map do |entry|
      item_entity = item_entity_name(entry[:entity])
      exposed = exposed_fields(item_entity)
      entry[:fields].reject { |field| exposed.include?(field) }.map do |field|
        "#{entry[:endpoint]} fetches #{field}, but #{item_entity} does not expose it"
      end
    end
  end

  it 'detects the V3 metric endpoints' do
    expect(metric_endpoints.size).to be >= 100
  end

  it 'pairs every metric endpoint with a response entity' do
    expect(metric_endpoints.map { |entry| entry[:entity] }).to all(be_truthy)
  end

  it 'exposes every field requested through fetch_metric_data_v2' do
    expect(dropped_metric_fields).to be_empty
  end

  # Single-metric endpoints whose entity used to expose a name the route never
  # requested, so the metric silently disappeared from the response.
  {
    'NewIssueCountItem' => 'issue_new_count',
    'IssueCommentCountItem' => 'issue_comment_activity',
    'CommunityContributorCountItem' => 'total_active_contributors',
    'ActiveCodeContributorCountItem' => 'code_contributors',
    'NonCodeContributorCountItem' => 'non_code_contributors',
    'ParticipatingOrgsItem' => 'participating_orgs',
    'OrgCodeContributorsItem' => 'org_code_contributors',
    'OrgNonCodeContributorsItem' => 'org_non_code_contributors',
    'GovernanceOrgsItem' => 'governance_orgs',
    'OrgManagersItem' => 'org_managers',
    'IndividualCodeContributorsItem' => 'individual_code_contributors',
    'IndividualNonCodeContributorsItem' => 'individual_non_code_contributors',
    'IndividualManagersItem' => 'individual_managers'
  }.each do |item_entity, field|
    it "exposes #{field} on #{item_entity}" do
      expect(exposed_metric_fields(item_entity)).to contain_exactly(field)
    end
  end
end
