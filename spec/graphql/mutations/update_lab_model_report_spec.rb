require 'rails_helper'

RSpec.describe Mutations::UpdateLabModelReport do
  let(:report) do
    LabModelReport.new(lab_model_id: 20, lab_model_version_id: 30, user_id: 1, is_public: false).tap do |record|
      record.save!(validate: false)
    end
  end
  let(:dataset) do
    LabDataset.new(lab_model_version_id: 30, lab_model_report_id: report.id, content: '[]').tap do |record|
      record.save!(validate: false)
      report.update_column(:lab_dataset_id, record.id)
    end
  end
  let(:schema) do
    mutation_class = described_class
    mutation_type = Class.new(GraphQL::Schema::Object) do
      graphql_name 'ReportUpdateTestMutation'
      field :update_lab_model_report, mutation: mutation_class
    end
    Class.new(GraphQL::Schema) { mutation(mutation_type) }
  end

  def execute_update(input, fields = 'id labModelId labModelVersionId labDatasetId userId')
    schema.execute(
      "mutation($input: UpdateLabModelReportInput!) { updateLabModelReport(input: $input) { data { #{fields} } } }",
      variables: { input: input }, context: { current_user: double('current user') }
    ).to_h
  end

  def expected_report_data
    { 'id' => report.id, 'labModelId' => 20, 'labModelVersionId' => 30,
      'labDatasetId' => dataset.id, 'userId' => 1 }
  end

  it 'returns report fields after changing visibility' do
    dataset
    result = execute_update({ reportId: report.id, isPublic: true })

    expect(result['errors']).to be_nil
    expect(result.dig('data', 'updateLabModelReport', 'data')).to eq(expected_report_data)
    expect(report.reload.is_public).to be(true)
    expect(dataset.reload.content).to eq('[]')
  end

  it 'updates the dataset while returning the report' do
    dataset
    rows = [{ 'label' => 'https://github.com/example/project', 'level' => 'repo' }]
    result = execute_update({ reportId: report.id, datasets: rows })

    expect(result['errors']).to be_nil
    expect(result.dig('data', 'updateLabModelReport', 'data')).to eq(expected_report_data)
    expect(JSON.parse(dataset.reload.content)).to eq(rows)
  end

  it 'returns the report for a visibility-only update without a dataset' do
    result = execute_update({ reportId: report.id, isPublic: true }, 'id')

    expect(result['errors']).to be_nil
    expect(result.dig('data', 'updateLabModelReport', 'data', 'id')).to eq(report.id)
    expect(report.reload.is_public).to be(true)
  end
end
