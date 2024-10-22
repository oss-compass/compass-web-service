# == Schema Information
#
# Table name: lab_datasets
#
#  id                   :bigint           not null, primary key
#  ident                :string(255)
#  name                 :string(255)
#  lab_model_version_id :integer          not null
#  content              :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#  lab_model_report_id  :bigint
#
require 'digest/md5'

class LabDataset < ApplicationRecord
  Limit = 10

  class ValidateFailed < StandardError; end

  belongs_to :lab_model_version
  belongs_to :lab_model_report

  def self.create_and_validate!(version, datasets)

    filtered_rows =
      datasets
        .map { |row| row.to_h.merge(label: ShortenedLabel.normalize_label(row.label)) }


    raise ValidateFailed.new(I18n.t('lab_models.invalid_dataset')) if filtered_rows.blank?
    raise ValidateFailed.new(I18n.t('lab_models.datasets_too_large', limit: Limit)) if filtered_rows.length > Limit

    content = JSON.dump(filtered_rows)
    self.create!(ident: Digest::MD5.hexdigest(content), content: content, lab_model_version: version)
  end

  def self.create_report_and_validate!(version, datasets,report)

    filtered_rows =
      datasets
        .map { |row| row.to_h.merge(label: ShortenedLabel.normalize_label(row.label)) }


    raise ValidateFailed.new(I18n.t('lab_models.invalid_dataset')) if filtered_rows.blank?
    raise ValidateFailed.new(I18n.t('lab_models.datasets_too_large', limit: Limit)) if filtered_rows.length > Limit

    content = JSON.dump(filtered_rows)
    self.create!(ident: Digest::MD5.hexdigest(content), content: content, lab_model_version: version, lab_model_report: report)
  end


  def update_rows!(datasets)
    filtered_rows =
      datasets
        .map { |row| row.to_h.merge(label: ShortenedLabel.normalize_label(row.label)) }
        .filter { |row| ActivityMetric.exist_one?('label', row[:label]) }

    raise ValidateFailed.new(I18n.t('lab_models.invalid_dataset')) if filtered_rows.blank?
    raise ValidateFailed.new(I18n.t('lab_models.datasets_too_large', limit: Limit)) if filtered_rows.length > Limit

    content = JSON.dump(filtered_rows)
    self.update!(ident: Digest::MD5.hexdigest(content), content: content)
  end

  def items
    JSON.parse(content)
      .map { |row| row.is_a?(String) ? { 'label' => row, 'level' => 'repo' } : row }
      .map { |item| item.merge({ 'short_code' => ShortenedLabel.convert(item['label'], item['level']) }) }
  rescue
    []
  end
end
