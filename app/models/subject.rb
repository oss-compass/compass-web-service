# == Schema Information
#
# Table name: subjects
#
#  id                :bigint           not null, primary key
#  label             :string(255)      not null
#  level             :string(255)      default("repo"), not null
#  status            :string(255)      default("pending"), not null
#  count             :integer          default(0), not null
#  status_updated_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  collect_at        :datetime
#  complete_at       :datetime
#
# Indexes
#
#  index_subjects_on_label  (label) UNIQUE
#
class Subject < ApplicationRecord
  PENDING = 'pending'
  PROGRESS = 'progress'
  COMPLETE = 'complete'
  UNKNOWN = 'unknown'

  has_many :subject_refs_as_child, class_name: 'SubjectRef', foreign_key: 'child_id'
  has_many :subject_refs_as_parent, class_name: 'SubjectRef', foreign_key: 'parent_id', dependent: :destroy
  has_many :childs, through: :subject_refs_as_parent
  has_many :parents, through: :subject_refs_as_child

  has_many :software_repos, -> { where("subject_refs.sub_type = ?", SubjectRef::Software) }, through: :subject_refs_as_parent, source: :child
  has_many :governance_repos, -> { where("subject_refs.sub_type = ?", SubjectRef::Governance) }, through: :subject_refs_as_parent, source: :child

  has_many :subscriptions, dependent: :destroy
  has_many :subject_access_levels, dependent: :destroy

  has_many_attached :exports

  validates :label, presence: true, length: { maximum: 255 }
  validates :level, presence: true, length: { maximum: 255 }
  validates :status, presence: true, length: { maximum: 255 }
  validates :count, presence: true

  def self.extract_repos_count(label, level)
    if level == 'community'
      subject = self.find_by(label: label, level: level)
      subject ? subject.count : 1
    else
      1
    end
  end

  def self.task_status_converter(task_status)
    case task_status.to_s
    when ProjectTask::Success, ProjectTask::Error, ProjectTask::Canceled
      COMPLETE
    when ProjectTask::Progress
      PROGRESS
    when ProjectTask::Pending
      PENDING
    else
      UNKNOWN
    end
  end

  def self.append_child(parent, label, type)
    append_child!(parent, label, type)
  rescue => ex
    Rails.logger.error "Unable to append child #{label} to #{parent&.label}, error: #{error}"
  end

  def self.remove_child(parent, label, type)
    remove_child!(parent, label, type)
  rescue => ex
    Rails.logger.error "Unable to remove child #{label} from #{parent&.label}, error: #{error}"
  end

  def self.append_child!(parent, label, type)
    child = Subject.find_or_initialize_by(label: label)
    child.level ||= 'repo'
    child.status ||= Subject::PENDING
    child.count = 1
    child.status_updated_at ||= Time.current
    child.save!
    SubjectRef.create!(parent: parent, child: child, sub_type: type)
  end

  def self.remove_child!(parent, label, type)
    child = Subject.find_by(label: label)
    SubjectRef.where(parent: parent, child: child, sub_type: type).destroy_all if child
  end

  def self.sync_subject_repos_refs(subject, new_software_repos: [], new_governance_repos: [])
    stable_software_repos = subject.software_repos.pluck('label')

    (new_software_repos - stable_software_repos).each do |label|
      append_child(subject, label, SubjectRef::Software)
    end

    (stable_software_repos - new_software_repos).each do |label|
      remove_child(subject, label, SubjectRef::Software)
    end

    stable_governance_repos = subject.governance_repos.pluck('label')

    (new_governance_repos - stable_governance_repos).each do |label|
      append_child(subject, label, SubjectRef::Governance)
    end

    (stable_governance_repos - new_governance_repos).each do |label|
      remove_child(subject, label, SubjectRef::Governance)
    end
  end

  def add_privileged_access_level!(user)
    return if user.blank?
    new_access_level = subject_access_levels.find_or_initialize_by(user: user)
    new_access_level.access_level = SubjectAccessLevel::PRIVILEGED_LEVEL
    new_access_level.save!
  end

  def to_project_row
    {
      level: level,
      label: label,
      status: status,
      updated_at: status_updated_at,
      short_code: ShortenedLabel.convert(label, level)
    }
  end

  def short_name
    if level == 'community'
      "#{label}-#{level}"
    else
      label.split('/').last(2).<<(level).join('-')
    end
  end
end
