if ENV['COMPASS_DATASET_ROWS_NATIVE'] == '1'
  require_relative '../support/lab_dataset_rows_native'
else
  require 'test_helper'
end

class LabDatasetRowsTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
    @mutation = Mutations::CreateLabDataset.new(
      object: nil, context: GraphQL::Query::NullContext.instance, field: nil
    )
  end

  def test_merge_preserves_all_legacy_string_rows
    content = [url('old-one'), url('old-two')].to_json
    merged = JSON.parse(@mutation.merge_dataset(content, [input(url('new-three'))]))
    assert_equal [url('old-one'), url('old-two'), url('new-three')], merged.map { |row| row['label'] }
  end

  def test_existing_legacy_string_is_not_new
    assert_empty @mutation.get_new_dataset([url('old-one')].to_json, [input(url('old-one'))])
  end

  def test_new_rows_are_stored_with_normalized_urls
    merged = JSON.parse(@mutation.merge_dataset('[]', [input('https://GITHUB.COM/Owner/Repo?tab=readme#top')]))
    assert_equal ['https://github.com/Owner/Repo'], merged.map { |row| row['label'] }
  end

  def test_equivalent_new_url_does_not_schedule_an_existing_repo
    existing = [{ label: url('Repo'), level: 'repo' }].to_json
    assert_empty @mutation.get_new_dataset(existing, [input('https://GITHUB.COM/dataset-row-native/Repo?tab=readme')])
  end

  def test_equivalent_new_url_does_not_duplicate_a_stored_row
    existing = [{ label: url('Repo'), level: 'repo' }].to_json
    merged = JSON.parse(@mutation.merge_dataset(existing, [input('https://GITHUB.COM/dataset-row-native/Repo#top')]))
    assert_equal 1, merged.length
  end

  def test_existing_url_is_normalized_before_matching
    existing = [{ label: 'https://GITHUB.COM/dataset-row-native/Repo?tab=readme', level: 'repo',
                  first_ident: 'original' }].to_json
    merged = JSON.parse(@mutation.merge_dataset(existing, [input(url('Repo'), first: 'replacement')]))
    assert_equal 1, merged.length
    assert_equal url('Repo'), merged.first['label']
    assert_equal 'original', merged.first['first_ident']
  end

  def test_remaining_new_rows_have_the_same_normalized_hash_shape
    rows = @mutation.get_new_dataset([{ label: url('old'), level: 'repo' }].to_json,
                                    [input('https://GITHUB.COM/dataset-row-native/New?tab=readme')])
    assert_equal [{ label: url('New'), level: 'repo' }], rows
  end

  def test_equivalent_new_rows_schedule_only_one_analysis
    rows = @mutation.get_new_dataset('[]', [input(url('Repo')), input(url('Repo') + '#top')])
    assert_equal [url('Repo')], rows.map { |row| row[:label] }
  end

  def test_equivalent_new_rows_merge_once_and_keep_first_metadata
    merged = JSON.parse(@mutation.merge_dataset('[]', [input(url('Repo'), first: 'first'),
                                                       input(url('Repo') + '?tab=readme', first: 'second')]))
    assert_equal 1, merged.length
    assert_equal 'first', merged.first['first_ident']
  end

  def test_empty_batch_raises_the_dataset_validation_error
    assert_raises(LabDataset::ValidateFailed) { @mutation.get_new_dataset(nil, []) }
  end

  def test_oversized_batch_raises_the_dataset_validation_error
    rows = 11.times.map { |number| input(url(number.to_s)) }
    assert_raises(LabDataset::ValidateFailed) { @mutation.get_new_dataset(nil, rows) }
  end

  def test_raw_batch_limit_is_checked_before_deduplication
    rows = 11.times.map { input(url('same')) }
    assert_raises(LabDataset::ValidateFailed) { @mutation.get_new_dataset(nil, rows) }
  end

  def test_initial_dataset_returns_normalized_rows
    rows = @mutation.get_new_dataset(nil, [input('https://GITHUB.COM/Owner/Repo#top')])
    assert_equal [{ label: 'https://github.com/Owner/Repo', level: 'repo' }], rows
  end

  def test_structured_existing_metadata_and_order_are_preserved
    original = [{ 'label' => url('old'), 'level' => 'repo', 'first_ident' => 'group',
                  'extra' => { 'kept' => ['nested', 3] } }]
    merged = JSON.parse(@mutation.merge_dataset(original.to_json, [input(url('new'))]))
    assert_equal original.first, merged.first
    assert_equal url('new'), merged.last['label']
  end

  def test_graphql_input_objects_are_not_modified
    row = input('https://GITHUB.COM/Owner/Repo#top', first: 'group', second: 'subgroup')
    original = row.to_h
    @mutation.merge_dataset('[]', [row])
    @mutation.get_new_dataset('[]', [row])
    assert_equal original, row.to_h
    assert_equal 'https://GITHUB.COM/Owner/Repo#top', row.label
  end

  def test_malformed_existing_json_is_not_replaced_by_a_merge
    assert_raises(JSON::ParserError) { @mutation.merge_dataset('{broken', [input(url('new'))]) }
  end

  def test_malformed_existing_json_is_not_treated_as_an_empty_difference
    assert_raises(JSON::ParserError) { @mutation.get_new_dataset('{broken', [input(url('new'))]) }
  end

  def test_exactly_ten_rows_are_accepted
    rows = 10.times.map { |number| input(url(number.to_s)) }
    assert_equal 10, @mutation.get_new_dataset(nil, rows).length
  end

  def test_existing_metadata_wins_for_an_exact_duplicate
    original = [{ 'label' => url('old'), 'level' => 'repo', 'first_ident' => 'original' }]
    merged = JSON.parse(@mutation.merge_dataset(original.to_json, [input(url('old'), first: 'replacement')]))
    assert_equal original, merged
  end

  def test_merged_legacy_rows_remain_readable_through_the_real_model
    old_labels = [url(SecureRandom.hex(6)), url(SecureRandom.hex(6))]
    new_label = url(SecureRandom.hex(6))
    content = @mutation.merge_dataset(old_labels.to_json, [input(new_label)])
    items = LabDataset.new(content: content).items
    assert_equal old_labels + [new_label], items.map { |row| row['label'] }
    assert items.all? { |row| row['short_code'].match?(/\As[0-9a-z]{7}\z/) }
  end

  def test_url_path_case_and_unicode_metadata_are_preserved
    merged = JSON.parse(@mutation.merge_dataset('[]', [input(url('MiXeD'), first: '分组', second: '子组')]))
    assert_equal url('MiXeD'), merged.first['label']
    assert_equal '分组', merged.first['first_ident']
    assert_equal '子组', merged.first['second_ident']
  end

  def test_non_url_community_names_are_preserved
    merged = JSON.parse(@mutation.merge_dataset('[]', [input('公共社区', level: 'community')]))
    assert_equal '公共社区', merged.first['label']
    assert_equal 'community', merged.first['level']
  end

  private

  def url(name)
    "https://github.com/dataset-row-native/#{name}"
  end

  def input(label, level: 'repo', first: nil, second: nil)
    value = { 'label' => label, 'level' => level }
    value['firstIdent'] = first unless first.nil?
    value['secondIdent'] = second unless second.nil?
    Input::DatasetRowTypeInput.coerce_input(value, GraphQL::Query::NullContext.instance)
  end
end
