# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/see_tags/text_tag'

require 'support/contracts/data/see_tag_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Docs::Data::SeeTags::TextTag do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:see_tag) { described_class.new(native:, parent:) }

  include_context 'with fixture files', 'see_tags'

  let(:fixture) { 'plain_text.rb' }
  let(:parent)  { YARD::Registry.find { |obj| obj.title == 'Space' } }
  let(:native)  { parent.tags.find { |tag| tag.tag_name == 'see' } }

  include_contract 'should be a see tag object',
    expected_json: -> { { 'text' => see_tag.text } }

  describe '.match?' do
    it { expect(described_class).to respond_to(:match?).with(1).argument }

    it { expect(described_class).to have_aliased_method(:match?).as(:matches?) }

    it { expect(described_class.match?(native)).to be true }

    wrap_context 'using fixture', 'class method' do
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'constant' do
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'definition' do
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'empty' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'instance method' do
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'link' do
      it { expect(described_class.match?(native)).to be false }
    end
  end

  describe '#as_json' do
    wrap_context 'using fixture', 'empty' do
      let(:expected) { { 'text' => nil } }

      it { expect(see_tag.as_json).to be == expected }
    end
  end

  describe '#text' do
    let(:expected) { 'This is a plain text message.' }

    include_examples 'should define reader', :text, -> { expected }

    wrap_context 'using fixture', 'empty' do
      it { expect(see_tag.text).to be nil }
    end
  end

  describe '#text?' do
    include_examples 'should define predicate', :text?, true

    wrap_context 'using fixture', 'empty' do
      it { expect(see_tag.text?).to be false }
    end
  end
end
