# == Schema Information
#
# Table name: lab_model_comments
#
#  id                   :bigint           not null, primary key
#  user_id              :integer          not null
#  content              :text(65535)      not null
#  reply_to             :integer
#  lab_model_id         :integer          not null
#  lab_model_version_id :integer
#  lab_model_metric_id  :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_comments_on_m_v_m               (lab_model_id,lab_model_version_id,lab_model_metric_id)
#  index_lab_model_comments_on_reply_to  (reply_to)
#  index_lab_model_comments_on_user_id   (user_id)
#
class LabModelComment < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64
  alias_attribute :model, :lab_model
  alias_attribute :images, :attachments
  alias_attribute :metric, :lab_model_metric

  has_many_base64_attached :attachments

  belongs_to :lab_model
  belongs_to :user
  belongs_to :lab_model_version, optional: true
  belongs_to :lab_model_metric, optional: true

  belongs_to :parent, class_name: "LabModelComment", foreign_key: 'reply_to', optional: true

  has_many :replies, class_name: "LabModelComment", foreign_key: 'reply_to', dependent: :destroy

  after_commit :purge_images, on: :destroy

  validates :content, presence: true

  def self.sortable_fields
    %w(created_at updated_at)
  end

  def self.sortable_directions
    %w(asc desc)
  end

  private

  def purge_images
    self.images.purge_later
  end
end
