# == Schema Information
#
# Table name: lab_models
#
#  id                 :bigint           not null, primary key
#  name               :string(255)      not null
#  user_id            :integer          not null
#  dimension          :integer          not null
#  is_general         :boolean          not null
#  is_public          :boolean          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  default_version_id :integer
#
class LabModel < ApplicationRecord
  alias_attribute :versions, :lab_model_versions
  alias_attribute :members, :lab_model_members
  alias_attribute :comments, :lab_model_comments
  alias_attribute :invitations, :lab_model_invitations

  belongs_to :mainline_version, class_name: 'LabModelVersion', foreign_key: :default_version_id, optional: true

  has_many :lab_model_versions, dependent: :delete_all
  has_many :lab_model_members, dependent: :delete_all
  has_many :lab_model_invitations, dependent: :delete_all

  has_many :lab_model_comments, dependent: :destroy # need to purge attachments

  validates :name, presence: true
  validates :user_id, presence: true
  validates :dimension, presence: true

  ## There should be no presence validates on boolean values, otherwise false won't pass validates
  # validates :is_general, presence: true
  # validates :is_public, presence: true

  CacheTTL = 1.day

  include Censoring

  censoring only: [:name]

  Productivity = 0
  Robustness = 1
  NicheCreation = 2
  LIMIT = 100

  Dimensions = [Productivity, Robustness, NicheCreation]

  def latest_versions
    # No paging for now, but limit the overall return to only the most recent 100 versions.
    versions.order('updated_at desc').limit(LIMIT)
  end

  def default_version
    mainline_version || versions.order('updated_at desc').first
  end

  def self.sortable_fields
    %w(created_at updated_at)
  end

  def self.sortable_directions
    %w(asc desc)
  end

  def has_member?(user)
    members.exists?(user: user)
  end

  def remaining_count_key
    "#{self.name}:#{self.id}:remaining_count"
  end

  def trigger_remaining_count
    default = ENV.fetch("LAB_MODEL_TRIGGER_COUNT") { 10 }
    count = Rails.cache.fetch(remaining_count_key, expires_in: CacheTTL, raw: true) { default }
    count.to_i
  end

  def decreasing_trigger_remaining_count
    Rails.cache.decrement(remaining_count_key)
  end
end
