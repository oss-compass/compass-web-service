# frozen_string_literal: true

require 'rails_helper'
require 'json'
require 'rack/mock'

RSpec.describe Openapi::CompassController::DashboardAlertController do
  let(:user) { double('authenticated user', id: 5, name: 'Tester', email: 'test@example.org') }
  let(:member) { double('dashboard membership', can_edit?: true) }
  let(:members) { double('dashboard membership persistence') }
  let(:dashboard_store) { double('Dashboard persistence') }
  let(:dashboard) do
    double('dashboard row', id: 7, public?: false,
           dashboard_members: members, dashboard_alert_rules: scope)
  end
  let(:target_repo) { 'https://gitee.com/example/project' }
  let(:scope) { double('alert rule relation') }
  let(:filtered_scope) { double('filtered alert rule relation') }
  let(:initial_type) { 'repository' }
  let(:save_succeeds) { true }
  let(:update_succeeds) { true }
  let(:creates) { [] }
  let(:updates) { [] }
  let(:row_json) do
    { 'id' => 11, 'dashboard_id' => 7, 'monitor_type' => initial_type,
      'target_repo' => target_repo, 'metric_key' => 'issue_total_count' }
  end
  let(:rule) do
    double('persisted alert rule', id: 11, dashboard: dashboard, creator: user,
           metric_key: 'issue_total_count', monitor_type: initial_type,
           as_json: row_json, save: save_succeeds)
  end
  let(:rows) { [rule] }
  let(:create_params) do
    { identifier: 'dashboard-1', monitorType: 'repo', targetRepo: target_repo,
      metricKey: 'issue_total_count', metricName: 'Total issues', timeRange: 3,
      operator: '>', operatorType: 'value', threshold: 10, level: 'warning' }
  end

  # Grape's own hook runs after endpoint helpers are installed and before its
  # filters. Only login/current-user dependencies are stubbed; the real member
  # and editor guards, validators and route bodies run unchanged.
  around do |example|
    previous_hooks = Grape::Endpoint.before_each.dup
    Grape::Endpoint.before_each do |endpoint|
      allow(endpoint).to receive(:require_login!).and_return(true)
      allow(endpoint).to receive(:current_user).and_return(user)
    end
    begin
      example.run
    ensure
      Grape::Endpoint.before_each.replace(previous_hooks)
    end
  end

  before do
    expect(DashboardAlertRule < ActiveRecord::Base).to be(true)
    expect(DashboardAlertRule.monitor_types).to eq('community' => 0, 'repository' => 1)
    stub_const('Dashboard', dashboard_store)
    allow(dashboard_store).to receive(:find_by).with({ identifier: 'dashboard-1' }).and_return(dashboard)
    allow(dashboard_store).to receive(:find_by!).with({ identifier: 'dashboard-1' }).and_return(dashboard)
    allow(members).to receive(:find_by).with({ user: user, status: :active }).and_return(member)
    allow(DashboardAlertRule).to receive(:new) do |attributes|
      creates << attributes.to_h.symbolize_keys
      rule
    end
    allow(DashboardAlertRule).to receive(:find).with(11).and_return(rule)
    allow(rule).to receive(:update) do |attributes|
      updates << attributes.to_h.symbolize_keys
      update_succeeds
    end
    allow(scope).to receive(:order).with({ created_at: :desc }).and_return(scope)
    allow(scope).to receive(:includes).with(:creator).and_return(scope)

    # Pagy and paginate_fun are real. Only the underlying count/read boundary
    # is doubled; no alias mapping or filtering algorithm is reproduced here.
    [scope, filtered_scope].each do |relation|
      allow(relation).to receive(:count).and_return(rows.length)
      allow(relation).to receive(:offset).and_return(relation)
      allow(relation).to receive(:limit).and_return(rows)
    end
  end

  def request(action, parameters)
    Rack::MockRequest.new(described_class).post(
      "/services/dashboard_alert/#{action}",
      'CONTENT_TYPE' => 'application/json', input: JSON.generate(parameters)
    )
  end

  def expect_success(response)
    expect(response.status).to eq(201)
    expect(JSON.parse(response.body)).to eq('success' => true)
  end

  def expect_list_filter(valid_values)
    expect(scope).to receive(:where).once do |attributes|
      expect(attributes.keys).to eq([:monitor_type])
      expect(valid_values).to include(attributes[:monitor_type])
      filtered_scope
    end
  end

  def expect_list(response)
    expect(response.status).to eq(201)
    data = JSON.parse(response.body)
    expect(data.keys).to match_array(%w[items totalCount currentPage perPage totalPages])
    expect(data).to include('totalCount' => rows.length, 'currentPage' => 1, 'totalPages' => 1)
    expect(data['perPage']).to eq(Pagy::DEFAULT.fetch(:items))
    expect(data['items']).to eq([
      { 'id' => 11, 'dashboard_id' => 7, 'monitor_type' => initial_type,
        'target_repo' => target_repo, 'metric_key' => 'issue_total_count', 'unit' => '个',
        'creator' => { 'user_id' => 5, 'user_name' => 'Tester', 'user_email' => 'test@example.org' } }
    ])
    response
  end

  it 'stores the accepted repo alias as the real repository enum when creating' do
    expect_success(request('create_rule', create_params))
    expect(creates).to eq([
      { dashboard_id: 7, creator_id: 5, monitor_type: 1, target_repo: target_repo,
        metric_key: 'issue_total_count', metric_name: 'Total issues', operator: '>',
        operator_type: 'value', time_range: 3, threshold: BigDecimal('10'),
        level: 1, description: nil, enabled: true }
    ])
  end

  it 'updates repo using the real repository enum' do
    expect_success(request('update_rule', id: 11, monitorType: 'repo', targetRepo: target_repo))
    expect(updates).to eq([{ monitor_type: 1, target_repo: target_repo }])
  end

  it 'filters repo rules using a registered repository enum value' do
    expect_list_filter([1, 'repository', :repository])
    response = expect_list(request('list_rules', identifier: 'dashboard-1', monitorType: 'repo'))
    expect(JSON.parse(response.body)['items'].map { |item| item['monitor_type'] }).to eq(['repository'])
  end

  it 'preserves community creation without a target repository' do
    parameters = create_params.merge(monitorType: 'community').except(:targetRepo)
    expect_success(request('create_rule', parameters))
    expect(creates.first.fetch(:monitor_type)).to eq(0)
    expect(creates.first.fetch(:target_repo)).to be_nil
  end

  it 'preserves an explicit community update' do
    expect_success(request('update_rule', id: 11, monitorType: 'community'))
    expect(updates).to eq([{ monitor_type: 0 }])
  end

  context 'when listing community rules' do
    let(:initial_type) { 'community' }

    it 'preserves the community filter and existing response names' do
      expect_list_filter([0, 'community', :community])
      response = expect_list(request('list_rules', identifier: 'dashboard-1', monitorType: 'community'))
      expect(JSON.parse(response.body)['items'].map { |item| item['monitor_type'] }).to eq(['community'])
    end
  end

  ['repository', 'community'].each do |stored_type|
    context "with an existing #{stored_type} rule" do
      let(:initial_type) { stored_type }

      it 'does not send a monitor_type update when monitorType is omitted' do
        expect_success(request('update_rule', id: 11, metricName: 'Changed name'))
        expect(updates).to eq([{ metric_name: 'Changed name' }])
      end
    end
  end

  it 'does not add a monitor filter when list monitorType is omitted' do
    expect(scope).not_to receive(:where)
    expect_list(request('list_rules', identifier: 'dashboard-1'))
  end

  {
    'create_rule' => { identifier: 'dashboard-1', monitorType: 'repository',
                       metricKey: 'issue_total_count', metricName: 'Total issues', timeRange: 3,
                       operator: '>', operatorType: 'value', threshold: 10, level: 'warning' },
    'update_rule' => { id: 11, monitorType: 'repository' },
    'list_rules' => { identifier: 'dashboard-1', monitorType: 'repository' }
  }.each do |action, parameters|
    it "keeps Grape's 400 validation for an invalid #{action} monitorType" do
      response = request(action, parameters)
      expect(response.status).to eq(400)
      expect(JSON.parse(response.body).fetch('error')).to include('monitorType')
      expect(creates).to be_empty
      expect(updates).to be_empty
    end
  end

  it 'preserves create repo targetRepo required validation' do
    response = request('create_rule', create_params.except(:targetRepo))
    expect(response.status).to eq(422)
    expect(JSON.parse(response.body)).to eq('success' => false)
    expect(creates).to be_empty
  end

  ['create_rule', 'update_rule', 'list_rules'].each do |action|
    context "without dashboard permission for #{action}" do
      let(:member) { nil }

      it 'preserves the real dashboard authorization guard' do
        parameters = case action
                     when 'create_rule' then create_params
                     when 'update_rule' then { id: 11, monitorType: 'repo' }
                     else { identifier: 'dashboard-1', monitorType: 'repo' }
                     end
        response = request(action, parameters)
        expect(response.status).to eq(403)
        expect(JSON.parse(response.body)).to have_key('error')
        expect(creates).to be_empty
        expect(updates).to be_empty
      end
    end
  end

  context 'when create persistence fails' do
    let(:save_succeeds) { false }

    it 'preserves the 422 failure response' do
      response = request('create_rule', create_params.merge(monitorType: 'community'))
      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)).to eq('success' => false)
    end
  end

  context 'when update persistence fails' do
    let(:update_succeeds) { false }

    it 'preserves the 422 failure response' do
      response = request('update_rule', id: 11, monitorType: 'community')
      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)).to eq('success' => false)
      expect(updates).to eq([{ monitor_type: 0 }])
    end
  end
end
