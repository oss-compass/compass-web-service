# frozen_string_literal: true
require 'spec_helper'
require 'graphql'
require 'active_support'
require 'active_support/core_ext/object/blank'

RSpec.describe 'UpdateLabModelVersion optional arguments' do
  before do
    stub_const('Types', Module.new)
    stub_const('Types::Lab', Module.new)
    version_type = Class.new(GraphQL::Schema::Object) do
      graphql_name 'VersionForOptionalArgsTest'
      field :id, Integer, null: false
    end
    stub_const('Types::Lab::ModelVersionType', version_type)
    stub_const('Input', Module.new)
    %w[DatasetRowTypeInput LabModelMetricInput].each do |name|
      input_type = Class.new(GraphQL::Schema::InputObject) do
        graphql_name "#{name}ForOptionalArgsTest"
        argument :id, Integer, required: false
      end
      stub_const("Input::#{name}", input_type)
    end
    stub_const('Mutations', Module.new)
    base = Class.new(GraphQL::Schema::RelayClassicMutation) do
      graphql_name 'BaseMutationForOptionalArgsTest'
      field :message, String, null: true
      def login_required!(user)
        raise GraphQL::ExecutionError, 'Login required' unless user
      end
    end
    stub_const('Mutations::BaseMutation', base)
    load File.expand_path('../../app/graphql/mutations/update_lab_model_version.rb', __dir__)
    mutation = Class.new(GraphQL::Schema::Object) do
      graphql_name 'MutationForOptionalArgsTest'
      field :update, mutation: Mutations::UpdateLabModelVersion
    end
    @schema = Class.new(GraphQL::Schema)
    @schema.mutation(mutation)

    @version = double(id: 2)
    allow(@version).to receive(:update!)
    versions = double
    allow(versions).to receive(:find_by).with({ id: 2 }).and_return(@version)
    @model = double(versions: versions)
    stub_const('LabModel', Class.new do
      def self.find_by(*); end
    end)
    allow(LabModel).to receive(:find_by).with({ id: 1 }).and_return(@model)
    stub_const('LabMetric', Class.new)
    stub_const('LabMetric::Limit', 20)
    stub_const('Pundit', Module.new do
      def self.policy(*); end
    end)
    allow(Pundit).to receive(:policy).and_return(double(update?: true))
    stub_const('ActiveRecord', Module.new)
    stub_const('ActiveRecord::Base', Class.new do
      def self.transaction
        yield
      end
    end)
  end

  def execute(arguments)
    @schema.execute(
      "mutation { update(input: { modelId: 1, versionId: 2, #{arguments} }) { data { id } } }",
      context: { current_user: double(id: 1) }
    ).to_h
  end

  it 'allows a version-only update without an algorithm argument' do
    expect(execute('version: "v2"')['errors']).to be_nil
    expect(@version).to have_received(:update!).with({ version: 'v2' }).once
    expect(@version).not_to have_received(:update!).with({ is_score: anything })
  end

  it 'does not reset score mode when isScore is omitted' do
    expect(execute('version: "v2", algorithm: null')['errors']).to be_nil
    expect(@version).not_to have_received(:update!).with({ is_score: anything })
  end

  [true, false].each do |value|
    it "retains an explicit isScore: #{value}" do
      expect(execute("isScore: #{value}, algorithm: null")['errors']).to be_nil
      expect(@version).to have_received(:update!).with({ is_score: value }).once
    end
  end

  it 'keeps an explicit null score unchanged' do
    expect(execute('isScore: null, algorithm: null')['errors']).to be_nil
    expect(@version).not_to have_received(:update!)
  end
end
