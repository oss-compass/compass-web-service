# frozen_string_literal: true

require 'rails_helper'
require 'json'
require 'faraday'
require 'faraday/adapter/test'

RSpec.describe IssueServer do
  let(:repo_url) { 'https://gitee.com/example/project' }
  let(:token) { 'test-issue-token' }
  let(:title) { 'Issue title' }
  let(:body) { 'Issue body' }
  let(:number) { 'I12ABC' }
  let(:issue_url) { 'https://gitee.com/example/project/issues/I12ABC' }
  let(:server) { described_class.new({ repo_url: repo_url, gitee_token: token }) }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Faraday::Connection.new { |builder| builder.adapter :test, stubs } }
  let(:success_body) { '{"html_url":"https://gitee.com/example/project/issues/I12ABC","id":7}' }

  # Only the HTTP transport is replaced. Public IssueServer methods and the
  # complete GiteeApplication helpers use genuine Faraday requests/responses.
  around do |example|
    previous_connection = Faraday.default_connection
    begin
      Faraday.default_connection = connection
      example.run
    ensure
      Faraday.default_connection = previous_connection
    end
  end

  after { stubs.verify_stubbed_calls }

  def check_request(env)
    expect(env.url.to_s).to eq(endpoint)
    expect(env.request_headers['Content-Type']).to eq('application/json')
    expect(JSON.parse(env.body)).to eq(expected_payload)
  end

  def respond_with(status, response_body)
    stubs.public_send(http_method, endpoint) do |env|
      check_request(env)
      [status, { 'Content-Type' => 'application/json' }, response_body]
    end
  end

  shared_examples 'a Gitee issue write' do
    it 'returns the raw JSON error as a failed public service result' do
      error_body = '{"message":"write rejected"}'
      respond_with(error_status, error_body)

      expect(result).to eq(status: false, message: error_body)
    end

    it 'rejects HTTP redirects even when their JSON body resembles success' do
      respond_with(302, success_body)

      expect(result).to eq(status: false, message: success_body)
    end

    it 'preserves the successful response shape' do
      respond_with(success_status, success_body)

      expect(result).to eq(success_result)
    end

    it 'preserves the existing translated transport-exception result' do
      stubs.public_send(http_method, endpoint) do |env|
        check_request(env)
        raise Faraday::ConnectionFailed, 'test transport failure'
      end
      expect(I18n.exists?('oauth.issue.failed')).to be(true)

      expect(result).to eq(
        status: false,
        message: I18n.t('oauth.issue.failed', reason: 'test transport failure')
      )
    end

    [:success_status, :error_status].each do |status_name|
      it "preserves the JSON-parser exception result for #{status_name}" do
        invalid_json = '{'
        parser_error = begin
          JSON.parse(invalid_json)
        rescue JSON::ParserError => error
          error
        end
        expect(parser_error).to be_a(JSON::ParserError)
        expect(I18n.exists?('oauth.issue.failed')).to be(true)
        respond_with(public_send(status_name), invalid_json)

        expect(result).to eq(
          status: false,
          message: I18n.t('oauth.issue.failed', reason: parser_error.message)
        )
      end
    end
  end

  describe '#create_gitee_issue' do
    subject(:result) { server.create_gitee_issue(title, body) }
    let(:http_method) { :post }
    let(:endpoint) { 'https://gitee.com/api/v5/repos/example/issues' }
    let(:error_status) { 401 }
    let(:success_status) { 201 }
    let(:success_result) { { status: true, issue_url: issue_url } }
    let(:expected_payload) do
      { 'repo' => 'project', 'title' => title, 'body' => body, 'access_token' => token }
    end

    include_examples 'a Gitee issue write'
  end

  describe '#create_gitee_issue_comment' do
    subject(:result) { server.create_gitee_issue_comment(number, body) }
    let(:http_method) { :post }
    let(:endpoint) { 'https://gitee.com/api/v5/repos/example/project/issues/I12ABC/comments' }
    let(:error_status) { 403 }
    let(:success_status) { 201 }
    let(:success_result) { { status: true, message: '' } }
    let(:expected_payload) { { 'body' => body, 'access_token' => token } }

    include_examples 'a Gitee issue write'
  end

  describe '#update_gitee_issue_title' do
    subject(:result) { server.update_gitee_issue_title(number, title) }
    let(:http_method) { :patch }
    let(:endpoint) { 'https://gitee.com/api/v5/repos/example/issues/I12ABC' }
    let(:error_status) { 422 }
    let(:success_status) { 200 }
    let(:success_result) { { status: true, message: '' } }
    let(:expected_payload) do
      { 'repo' => 'project', 'title' => title, 'body' => nil, 'access_token' => token }
    end

    include_examples 'a Gitee issue write'
  end

  describe '#update_gitee_issue_body' do
    subject(:result) { server.update_gitee_issue_body(number, body) }
    let(:http_method) { :patch }
    let(:endpoint) { 'https://gitee.com/api/v5/repos/example/issues/I12ABC' }
    let(:error_status) { 500 }
    let(:success_status) { 200 }
    let(:success_result) { { status: true, message: '' } }
    let(:expected_payload) do
      { 'repo' => 'project', 'title' => nil, 'body' => body, 'access_token' => token }
    end

    include_examples 'a Gitee issue write'
  end
end
