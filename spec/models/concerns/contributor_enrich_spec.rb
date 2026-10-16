# frozen_string_literal: true

require 'rails_helper'

# The contribution domain portrait (领域画像) draws one horizontal bar per
# contributor and derives the width of every segment from the contribution
# types returned by the enrichment index. `code_commit` used to aggregate both
# the commits pushed directly to a branch and the commits merged through a pull
# request, so keeping it next to `code_direct_commit` / `code_pr_commit` counts
# the same commits twice and makes the bars of the portrait overlap. These specs
# pin the normalization that removes the aggregate from the payload served to
# the contribution domain portrait.
RSpec.describe ContributorEnrich do
  def contribution_row(contribution_type, contribution)
    { 'contribution_type' => contribution_type, 'contribution' => contribution }
  end

  def types_of(contribution_type_list)
    contribution_type_list.map { |item| item['contribution_type'] }
  end

  def total_of(contribution_type_list)
    contribution_type_list.sum { |item| item['contribution'].to_i }
  end

  shared_examples 'a normalized contribution type list' do
    it 'drops code_commit when code_direct_commit and code_pr_commit are reported' do
      list = [
        contribution_row('code_commit', 6),
        contribution_row('code_direct_commit', 2),
        contribution_row('code_pr_commit', 4)
      ]

      expect(indexer.normalize_contribution_type_list(list)).to eq(
        [contribution_row('code_direct_commit', 2), contribution_row('code_pr_commit', 4)]
      )
    end

    it 'drops code_commit as soon as one of its replacement types is reported' do
      list = [contribution_row('code_commit', 3), contribution_row('code_direct_commit', 3)]

      expect(types_of(indexer.normalize_contribution_type_list(list))).to eq(%w[code_direct_commit])
    end

    it 'keeps code_commit for records that only carry the historical type' do
      list = [contribution_row('code_commit', 5), contribution_row('issue_creation', 1)]

      expect(indexer.normalize_contribution_type_list(list)).to eq(list)
    end

    it 'never drops code_direct_commit and code_pr_commit themselves' do
      list = [contribution_row('code_pr_commit', 4), contribution_row('code_direct_commit', 2)]

      expect(indexer.normalize_contribution_type_list(list)).to eq(list)
    end

    it 'sums the same contribution type when it is reported for several days' do
      list = [
        contribution_row('code_pr_commit', 2),
        contribution_row('star', 1),
        contribution_row('code_pr_commit', 3)
      ]

      expect(indexer.normalize_contribution_type_list(list)).to eq(
        [contribution_row('code_pr_commit', 5), contribution_row('star', 1)]
      )
    end

    it 'normalizes contribution counters returned as strings' do
      list = [contribution_row('code_pr_commit', '2'), contribution_row('code_pr_commit', 3)]

      expect(indexer.normalize_contribution_type_list(list)).to eq([contribution_row('code_pr_commit', 5)])
    end

    it 'ignores entries that are not contribution rows' do
      list = [nil, 'code_commit', contribution_row('code_commit', 4)]

      expect(indexer.normalize_contribution_type_list(list)).to eq([contribution_row('code_commit', 4)])
    end

    it 'returns an empty list when nothing was reported' do
      expect([
        indexer.normalize_contribution_type_list(nil),
        indexer.normalize_contribution_type_list([])
      ]).to eq([[], []])
    end

    it 'does not mutate the list it was given' do
      list = [contribution_row('code_commit', 6), contribution_row('code_direct_commit', 6)]

      indexer.normalize_contribution_type_list(list)

      expect(types_of(list)).to eq(%w[code_commit code_direct_commit])
    end

    it 'keeps the contribution total of the split types unchanged' do
      list = [
        contribution_row('code_commit', 6),
        contribution_row('code_direct_commit', 2),
        contribution_row('code_pr_commit', 4)
      ]

      expect(total_of(indexer.normalize_contribution_type_list(list))).to eq(6)
    end
  end

  describe GithubContributorEnrich do
    let(:indexer) { described_class }

    include_examples 'a normalized contribution type list'
  end

  describe GiteeContributorEnrich do
    let(:indexer) { described_class }

    include_examples 'a normalized contribution type list'
  end

  describe GitcodeContributorEnrich do
    let(:indexer) { described_class }

    include_examples 'a normalized contribution type list'
  end

  describe '.merge_contributor' do
    let(:indexer) { GithubContributorEnrich }

    let(:first_day) do
      {
        'contributor' => 'alice',
        'contribution' => 8,
        'contribution_without_observe' => 8,
        'ecological_type' => 'individual participant',
        'organization' => nil,
        'contribution_type_list' => [
          contribution_row('code_commit', 6),
          contribution_row('code_direct_commit', 6)
        ]
      }
    end

    let(:second_day) do
      {
        'contributor' => 'alice',
        'contribution' => 3,
        'contribution_without_observe' => 3,
        'ecological_type' => 'individual participant',
        'organization' => nil,
        'contribution_type_list' => [
          contribution_row('code_pr_commit', 2),
          contribution_row('issue_creation', 1)
        ]
      }
    end

    it 'does not keep code_commit next to the types that replaced it' do
      merged = indexer.merge_contributor(first_day, second_day)

      expect(types_of(merged['contribution_type_list'])).to eq(
        %w[code_direct_commit code_pr_commit issue_creation]
      )
    end

    it 'still sums the contribution counters reported by the enrichment' do
      merged = indexer.merge_contributor(first_day, second_day)

      expect([merged['contribution'], merged['contribution_without_observe']]).to eq([11, 11])
    end

    it 'keeps code_commit for contributors that only report the historical type' do
      historical_day = first_day.merge(
        'contribution_type_list' => [contribution_row('code_commit', 6)]
      )
      last_day = second_day.merge(
        'contribution_type_list' => [contribution_row('issue_creation', 1)]
      )

      merged = indexer.merge_contributor(historical_day, last_day)

      expect(types_of(merged['contribution_type_list'])).to eq(%w[code_commit issue_creation])
    end
  end
end
