# frozen_string_literal: true
require 'spec_helper'
require 'json'
require 'active_support'
require 'active_support/core_ext/object/blank'

RSpec.describe 'AnalyzeGroupServer workflow switches' do
  flag_fields = {
    raw: :raw, enrich: :enrich, identities_load: :identities_load,
    identities_merge: :identities_merge, activity: :metrics_activity,
    community: :metrics_community, codequality: :metrics_codequality,
    group_activity: :metrics_group_activity, domain_persona: :metrics_domain_persona,
    milestone_persona: :metrics_milestone_persona, role_persona: :metrics_role_persona
  }.freeze

  before do
    stub_const('Common', Module.new)
    stub_const('CompassUtils', Module.new)
    stub_const('AnalyzeGroupServer', Class.new)
    load File.expand_path('../../app/services/analyze_group_server.rb', __dir__)
    stub_const('CELERY_SERVER', 'https://workflow.example')
    stub_const('Faraday', Class.new do
      def self.post(*); end
    end)
    allow(Faraday).to receive(:post).and_return(double(body: '{"status":"pending"}'))
  end

  it 'enables all switches when they are omitted' do
    server = AnalyzeGroupServer.new
    expect(server.execute_workflow[:status]).to eq(true)
    expect(Faraday).to have_received(:post) do |_url, body, _headers|
      payload = JSON.parse(body)['payload']
      flag_fields.each_value { |field| expect(payload[field.to_s]).to eq(true) }
    end
  end

  flag_fields.each do |option, field|
    it "preserves an explicit false for #{option} in the submitted payload" do
      server = AnalyzeGroupServer.new(option => false)
      expect(server.execute_workflow[:status]).to eq(true)
      expect(Faraday).to have_received(:post) do |_url, body, _headers|
        payload = JSON.parse(body)['payload']
        expect(payload[field.to_s]).to eq(false)
        (flag_fields.values - [field]).each { |other| expect(payload[other.to_s]).to eq(true) }
      end
    end
  end

  it 'rejects a request with all tasks explicitly disabled before submitting work' do
    server = AnalyzeGroupServer.new(flag_fields.transform_values { false }.merge(raw_yaml: 'community_name: demo'))
    expect(server.execute).to eq(status: nil, message: 'No tasks enabled')
    expect(Faraday).not_to have_received(:post)
  end
end
