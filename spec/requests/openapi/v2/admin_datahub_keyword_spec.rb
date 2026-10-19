# frozen_string_literal: true

require 'rails_helper'
require 'json'
require 'rack/mock'

RSpec.describe Openapi::V2::Admin, type: :request do
  # Mount the complete production API without changing its helpers.
  # Only this isolated wrapper supplies the authentication boundary.
  let(:api) do
    admin_api = described_class
    Class.new(Grape::API) do
      helpers do
        def require_login!
          true
        end
      end

      mount admin_api
    end
  end

  let(:recorded_at) { Time.utc(2026, 10, 15, 12) }

  around do |example|
    ActiveRecord::Base.transaction(requires_new: true) do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  before do
    # Insert storage fixtures directly: credentials and Devise/review/job
    # callbacks are not part of owner lookup. No query or serializer is stubbed.
    User.insert_all!([
      {
        name: 'alice-owner', email: 'alice@example.test',
        encrypted_password: 'unused-query-fixture', role_level: 3,
        created_at: recorded_at, updated_at: recorded_at
      },
      {
        name: 'bob-owner', email: 'bob@example.test',
        encrypted_password: 'unused-query-fixture', role_level: 3,
        created_at: recorded_at, updated_at: recorded_at
      }
    ])
    @alice = User.find_by!(email: 'alice@example.test')
    @bob = User.find_by!(email: 'bob@example.test')

    [@alice, @bob].each do |owner|
      LoginBind.insert_all!([{
        user_id: owner.id, provider: 'github', account: owner.name,
        nickname: owner.name, uid: owner.id.to_s,
        avatar_url: 'https://example.test/avatar.png',
        created_at: recorded_at, updated_at: recorded_at
      }])
      TrackingRestapi.insert_all!([{
        user_id: owner.id, api_path: '/api/v2/metadata/releases',
        domain: 'api.example.test',
        created_at: recorded_at, updated_at: recorded_at
      }])
      TrackingEvent.insert_all!([{
        user_id: owner.id, event_type: 'module_click',
        timestamp: recorded_at.to_i * 1000, page_path: '/dataHub',
        module_id: 'dataHub',
        data: JSON.generate(type: 'archive_download', content: {
          dataset_name: 'Contributor Dataset'
        }),
        created_at: recorded_at, updated_at: recorded_at
      }])
    end
  end

  def usage_response(route, keywords)
    params = {
      begin_date: '2026-10-10', end_date: '2026-10-20',
      page: 1, per_page: 20, keywords: keywords
    }
    response = Rack::MockRequest.new(api).post(
      "/api/v2/admin/#{route}",
      'CONTENT_TYPE' => 'application/json', input: JSON.generate(params)
    )
    expect(response.status).to eq(201)
    body = JSON.parse(response.body)
    expect(body.keys).to include(
      'items', 'total_count', 'current_page', 'per_page', 'total_pages'
    )
    body
  end

  %w[datahub_restapi_table datahub_archive_download_table].each do |route|
    context route do
      it 'returns no usage when a nonempty keyword matches no owner' do
        body = usage_response(route, 'no-such-owner@example.test')

        expect(body['items']).to eq([])
        expect(body['total_count']).to eq(0)
      end

      it 'returns only the email-matching owner usage' do
        body = usage_response(route, 'alice@example.test')

        expect(body['items'].map { |item| item['user_id'] }).to eq([@alice.id])
        expect(body['total_count']).to eq(1)
      end

      it 'keeps all qualifying owners when keywords are empty' do
        body = usage_response(route, '')

        expect(body['items'].map { |item| item['user_id'] }.sort)
          .to eq([@alice.id, @bob.id].sort)
        expect(body['total_count']).to eq(2)
      end
    end
  end
end
