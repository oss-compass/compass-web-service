require 'rails_helper'

RSpec.describe LabModel, type: :model do
  describe 'destroying a model' do
    let(:algorithm) { LabAlgorithm.create!(ident: 'cleanup-spec') }
    let(:metric) { LabMetric.create!(name: 'Activity', ident: 'activity', category: 'activity') }

    before do
      stub_const('Censoring::Enable', false)
    end

    # Populate the stored graph without creation-time validations: versions and
    # datasets reference each other and must be linked after both exist.
    def persist(klass, attributes)
      klass.new(attributes).tap { |record| record.save!(validate: false) }
    end

    def model_graph(name)
      model = described_class.create!(name: name, user_id: 1, dimension: 0, is_general: false, is_public: false)
      versions = 2.times.map do |index|
        version = persist(LabModelVersion, lab_model_id: model.id, lab_algorithm_id: algorithm.id,
                          lab_dataset_id: 0, version: "v0.0.#{index + 1}")
        dataset = persist(LabDataset, lab_model_version_id: version.id, content: '[]')
        version.update_column(:lab_dataset_id, dataset.id)
        model_metric = LabModelMetric.create!(lab_model_version: version, lab_metric: metric, weight: 1.0)
        report = LabModelReport.create!(lab_model: model, lab_model_version: version, user_id: 1)
        report_dataset = persist(LabDataset, lab_model_version_id: version.id,
                                 lab_model_report_id: report.id, content: '[]')
        report.update_column(:lab_dataset_id, report_dataset.id)
        { version: version, metric: model_metric, dataset: dataset, report: report, report_dataset: report_dataset }
      end
      [model, versions]
    end

    it 'removes the metrics owned by every version' do
      model, versions = model_graph('Delete metrics')
      ids = versions.map { |graph| graph[:metric].id }

      model.destroy!

      expect(LabModelMetric.where(id: ids)).to be_empty
      expect(LabModelVersion.where(lab_model_id: model.id)).to be_empty
    end

    it 'removes version datasets and report datasets' do
      model, versions = model_graph('Delete datasets')
      ids = versions.flat_map { |graph| [graph[:dataset].id, graph[:report_dataset].id] }

      model.destroy!

      expect(LabDataset.where(id: ids)).to be_empty
      expect(LabModelReport.where(lab_model_id: model.id)).to be_empty
    end

    it 'preserves another model and the shared algorithm and metric definitions' do
      model, = model_graph('Delete this model')
      other, versions = model_graph('Keep this model')

      model.destroy!

      expect(described_class.exists?(other.id)).to be(true)
      versions.each do |graph|
        graph.each_value { |record| expect(record.class.exists?(record.id)).to be(true) }
      end
      expect(LabAlgorithm.exists?(algorithm.id)).to be(true)
      expect(LabMetric.exists?(metric.id)).to be(true)
    end
  end
end
