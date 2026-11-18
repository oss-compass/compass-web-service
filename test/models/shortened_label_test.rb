if ENV['COMPASS_SHORT_LABEL_NATIVE'] == '1'
  require_relative '../support/shortened_label_native'
else
  require 'test_helper'
end

class ShortenedLabelTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
  end

  def test_new_repository_gets_a_short_code
    record = make_label
    assert_match(/\As[0-9a-z]{7}\z/, record.short_code)
    assert_equal record.short_code, record.reload.short_code
  end

  def test_new_community_gets_a_short_code
    record = make_label(level: 'community')
    assert_match(/\Ac[0-9a-z]{7}\z/, record.short_code)
  end

  def test_validation_preserves_a_persisted_short_code
    record = make_label
    original_code = record.short_code
    assert record.valid?
    assert_equal original_code, record.short_code
  end

  def test_repeated_saves_preserve_the_published_short_code
    record = make_label
    original_code = record.short_code
    2.times { record.save! }
    assert_equal original_code, record.reload.short_code
  end

  def test_updating_the_label_keeps_the_existing_link
    record = make_label
    original_code = record.short_code
    replacement = unique_label
    record.update!(label: replacement)
    assert_equal original_code, record.reload.short_code
    assert_equal replacement, ShortenedLabel.find_by(short_code: original_code)&.label
  end

  def test_failed_validation_does_not_replace_the_short_code
    record = make_label
    original_code = record.short_code
    record.label = ''
    refute record.valid?
    assert_equal original_code, record.short_code
  end

  def test_custom_validation_context_keeps_the_short_code
    record = make_label
    original_code = record.short_code
    assert record.valid?(:import)
    assert_equal original_code, record.short_code
  end

  def test_create_context_on_an_existing_record_keeps_the_short_code
    record = make_label
    original_code = record.short_code
    assert record.valid?(:create)
    assert_equal original_code, record.short_code
  end

  def test_public_revert_resolves_the_original_code_after_a_save
    label = unique_label
    original_code = ShortenedLabel.convert(label, 'repo')
    record = ShortenedLabel.find_by!(label: label, level: 'repo')
    record.save!
    Rails.cache.clear
    assert_equal record.id, ShortenedLabel.revert(original_code)&.id
  end

  def test_repeated_conversion_reuses_the_same_record_and_code
    label = unique_label
    original_code = ShortenedLabel.convert(label, 'repo')
    assert_equal original_code, ShortenedLabel.convert(label, 'repo')
    assert_equal 1, ShortenedLabel.where(label: label, level: 'repo').count
  end

  def test_cache_expiration_keeps_the_stored_code
    label = unique_label
    original_code = ShortenedLabel.convert(label, 'repo')
    ShortenedLabel.expire_cache(label, 'repo')
    assert_equal original_code, ShortenedLabel.convert(label, 'repo')
  end

  def test_distinct_labels_have_distinct_codes
    first = make_label
    second = make_label
    refute_equal first.short_code, second.short_code
  end

  def test_a_duplicate_is_a_new_record_and_gets_its_own_code
    original = make_label
    duplicate = original.dup
    duplicate.label = unique_label
    duplicate.save!
    refute_equal original.short_code, duplicate.short_code
    assert_equal original.short_code, original.reload.short_code
  end

  private

  def unique_label
    "https://github.com/short-label-native/#{SecureRandom.hex(8)}"
  end

  def make_label(level: 'repo')
    ShortenedLabel.create!(label: unique_label, level: level)
  end
end
