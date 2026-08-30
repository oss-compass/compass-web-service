# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, '#has_privilege_to?' do
  subject(:user) { User.new(id: 42) }

  let(:subject_record) { double('Subject', id: 7) }
  let(:level_relation) { double('SubjectAccessLevel relation') }

  before do
    allow(Subject).to receive(:find_by).with(label: 'label', level: 'repo').and_return(subject_record)
    allow(SubjectRef).to receive(:where)
      .with('parent_id = ? OR child_id = ?', 7, 7)
      .and_return(double(pluck: [7, 8]))
    allow(level_relation).to receive(:where).and_return(level_relation)
    allow(level_relation).to receive(:exists?).and_return(false)
    allow(SubjectAccessLevel).to receive(:where).and_return(level_relation)
  end

  it 'checks the current user\'s access levels, not everyone\'s' do
    user.has_privilege_to?('label', 'repo')

    expect(level_relation).to have_received(:where).with(hash_including(user_id: 42))
    expect(level_relation).to have_received(:where).with(access_level: SubjectAccessLevel::PRIVILEGED_LEVEL)
    expect(level_relation).to have_received(:exists?)
  end

  it 'returns true only when the user has a privileged level on the subject or a linked subject' do
    allow(level_relation).to receive(:exists?).and_return(true)

    expect(user.has_privilege_to?('label', 'repo')).to be(true)
  end

  it 'returns false for unknown subjects' do
    allow(Subject).to receive(:find_by).and_return(nil)

    expect(user.has_privilege_to?('label', 'repo')).to be(false)
  end
end
