# == Schema Information
#
# Table name: subject_sigs
#
#  id               :bigint           not null, primary key
#  name             :string
#  description      :string
#  maintainers      :string
#  emails           :string
#  subject_ref_id   :integer
#  created_at       :datetime
#  updated_at       :datetime
#
# Indexes
#
#  index_subject_sigs_on_subject_ref_id  (subject_ref_id) UNIQUE
#
class SubjectSig < ApplicationRecord
  belongs_to :subject_ref

  def self.fetch_subject_sig_list_by_repo_urls(label, level, repo_urls, filter_opts: [])

    subject = Subject.find_by(label: label, level: level)
    raise GraphQL::ExecutionError.new I18n.t('label.not_found') if subject.nil?
    repo_subjects = Subject.select("subjects.*, subject_refs.parent_id, subject_refs.child_id")
                           .joins(:subject_refs_as_child)
                           .where(label: repo_urls, level: "repo")

    subject_sigs_query = SubjectSig.select("subject_sigs.*, subject_refs.parent_id, subject_refs.child_id")
                             .joins(:subject_ref)
                             .where("subject_refs.parent_id = ?", subject.id)
                             .where("subject_refs.child_id IN (?)", repo_subjects.map { |data| data.parent_id })
    if filter_opts.present?
      filter_opts.each do |filter_opt|
        if ["sig_name"].include?(filter_opt.type)
          subject_sigs_query.where("subject_sigs.name IN (?)", filter_opt.values)
        end
      end
    end
    subject_sigs = subject_sigs_query.all

    map_subject_sigs = subject_sigs.each_with_object({}) do |data, hash|
      hash[data.child_id] = data
    end

    repo_sig_list = repo_subjects.map do |data|
      next unless map_subject_sigs&.include?(data[:parent_id])
      sig_name = map_subject_sigs[data[:parent_id]]&.name
      data_hash = data.attributes.transform_keys(&:to_sym)
      data_hash[:sig_name] = sig_name
      data_hash
    end
    repo_sig_list.compact
  end
end
