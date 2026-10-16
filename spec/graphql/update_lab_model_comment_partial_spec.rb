# frozen_string_literal: true
require 'spec_helper'
require 'graphql'
require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/starts_ends_with'

RSpec.describe 'UpdateLabModelComment partial updates' do
  before do
    stub_const('Types', Module.new)
    stub_const('Types::Lab', Module.new)
    stub_const('Types::Lab::ModelCommentType', Class.new(GraphQL::Schema::Object) do
      graphql_name 'CommentForPartialUpdateTest'
      field :id, Integer, null: false
    end)
    stub_const('Input', Module.new)
    stub_const('Input::Base64ImageInput', Class.new(GraphQL::Schema::InputObject) do
      graphql_name 'ImageForPartialUpdateTest'
      argument :id, Integer, required: false
      argument :filename, String, required: true
      argument :base64, String, required: true
    end)
    stub_const('Mutations', Module.new)
    stub_const('Mutations::BaseMutation', Class.new(GraphQL::Schema::RelayClassicMutation) do
      graphql_name 'BaseForCommentPartialUpdateTest'
      def login_required!(user)
        raise GraphQL::ExecutionError, 'Login required' unless user
      end
    end)
    load File.expand_path('../../app/graphql/mutations/update_lab_model_comment.rb', __dir__)
    mutation = Class.new(GraphQL::Schema::Object) do
      graphql_name 'MutationForCommentPartialUpdateTest'
      field :update, mutation: Mutations::UpdateLabModelComment
    end
    @schema = Class.new(GraphQL::Schema)
    @schema.mutation(mutation)
    @images = double(purge: nil, attach: nil)
    @comment = double(id: 11, user_id: 1, images: @images)
    allow(@comment).to receive(:update!)
    comments = double
    allow(comments).to receive(:find_by).with({ id: 11 }).and_return(@comment)
    @model = double(comments: comments)
    stub_const('LabModel', Class.new do
      def self.find_by(*); end
    end)
    allow(LabModel).to receive(:find_by).with({ id: 1 }).and_return(@model)
    stub_const('Pundit', Module.new do
      def self.policy(*); end
    end)
    allow(Pundit).to receive(:policy).and_return(double(view?: true))
    stub_const('I18n', Module.new do
      def self.t(key, **)
        key
      end
    end)
  end

  def execute(arguments, user_id: 1)
    @schema.execute(
      "mutation { update(input: { modelId: 1, commentId: 11, #{arguments} }) { data { id } } }",
      context: { current_user: double(id: user_id) }
    ).to_h
  end

  it 'preserves existing images when updating only the text' do
    expect(execute('content: "new text"')['errors']).to be_nil
    expect(@comment).to have_received(:update!).with({ content: 'new text' })
    expect(@images).not_to have_received(:purge)
    expect(@images).not_to have_received(:attach)
  end

  it 'allows an image-only update without requiring replacement text' do
    expect(execute('images: [{filename: "image.png", base64: "data:image/png;base64,aA=="}]')['errors']).to be_nil
    expect(@comment).not_to have_received(:update!)
    expect(@images).to have_received(:attach).with({ data: 'data:image/png;base64,aA==', filename: 'image.png' })
  end

  it 'still removes images when an explicit empty list is supplied' do
    expect(execute('content: "new text", images: []')['errors']).to be_nil
    expect(@images).to have_received(:purge).once
  end

  it 'rejects explicit blank content without changing the comment' do
    expect(execute('content: " "')['errors'].first['message']).to eq('lab_models.content_required')
    expect(@comment).not_to have_received(:update!)
    expect(@images).not_to have_received(:purge)
  end

  it 'validates the image count before writing new text' do
    images = Array.new(6, '{filename: "image.png", base64: "data:image/png;base64,aA=="}').join(',')
    expect(execute("content: \"new text\", images: [#{images}]")['errors'].first['message']).to eq('lab_models.reach_limit')
    expect(@comment).not_to have_received(:update!)
    expect(@images).not_to have_received(:purge)
  end

  it 'still rejects changes by a different comment author' do
    expect(execute('content: "new text"', user_id: 2)['errors'].first['message']).to eq('lab_models.forbidden')
    expect(@comment).not_to have_received(:update!)
    expect(@images).not_to have_received(:purge)
  end
end
