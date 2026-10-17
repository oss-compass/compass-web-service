require 'rails_helper'
require 'json'
require 'ostruct'

RSpec.describe AnalyzeServer do
  describe '#execute with invalid developer organization dates' do
    let(:repo_url) { 'https://github.com/example/project' }
    let(:task_row) { nil }
    let(:organization_store) { double('ContributorOrg persistence boundary') }
    let(:repository_response) { double('repository response', code: 200) }
    let(:repository_request) { double('repository HTTP request', execute: repository_response) }
    let(:status_response) do
      double('workflow status response', body: JSON.generate('status' => ProjectTask::Success))
    end

    # Match the existing method-level baseline. URL normalization and the real
    # constructor are deliberately outside this regression's scope.
    subject(:server) do
      described_class.allocate.tap do |instance|
        {
          repo_url: repo_url,
          domain: 'github.com',
          domain_name: 'github',
          project_name: repo_url,
          raw: true,
          callback: { params: { pr_number: 42 } }
        }.each { |name, value| instance.instance_variable_set("@#{name}", value) }
      end
    end

    before do
      allow(ProjectTask).to receive(:find_by).with({ remote_url: repo_url }).and_return(task_row)
      allow(RestClient::Request).to receive(:new).with({
        method: :get,
        url: "#{repo_url}.git/info/refs?service=git-upload-pack",
        proxy: Common::PROXY
      }).and_return(repository_request)
      allow(Faraday).to receive(:get).with(
        "#{Common::CELERY_SERVER}/api/workflows/task-42"
      ).and_return(status_response)

      # These are only forbidden persistence/network boundaries. The complete
      # execute method, date parsing and ContributorOrgInput validator run intact.
      stub_const('ContributorOrg', organization_store)
      expect(organization_store).not_to receive(:import)
      expect(ProjectTask).not_to receive(:create)
      expect(Faraday).not_to receive(:post)

      if task_row
        allow(task_row).to receive(:update).with({ status: ProjectTask::Success }).and_return(true)
      end
    end

    shared_examples 'an organization date validation failure' do
      [
        [
          'overlapping ranges',
          [
            'alpha from 2020-01-01 until 2022-12-31',
            'beta from 2022-01-01 until 2024-12-31'
          ],
          'contributor_orgs.range_overlap'
        ],
        [
          'a reversed range',
          ['alpha from 2024-01-01 until 2023-01-01'],
          'contributor_orgs.range_invalid'
        ]
      ].each do |description, lines, translation_key|
        it "returns the original error for #{description} without submitting or persisting" do
          server.instance_variable_set(:@developers, { 'developer-1' => lines })
          expect(I18n.exists?(translation_key)).to be(true)
          expected_message = I18n.t(translation_key)

          result = server.execute(only_validate: false)

          expect(result).to eq(status: false, message: expected_message)
          if task_row
            # Refreshing an existing task occurs before developer validation;
            # no new workflow or contributor persistence follows the error.
            expect(task_row).to have_received(:update).with({ status: ProjectTask::Success }).once
            expect(Faraday).to have_received(:get).with(
              "#{Common::CELERY_SERVER}/api/workflows/task-42"
            ).once
          else
            expect(Faraday).not_to have_received(:get)
          end
        end
      end
    end

    context 'before the first ProjectTask exists' do
      include_examples 'an organization date validation failure'
    end

    context 'with an existing successful ProjectTask' do
      let(:task_row) do
        double('existing ProjectTask', task_id: 'task-42', status: ProjectTask::Success)
      end

      include_examples 'an organization date validation failure'
    end
  end
end
