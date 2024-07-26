# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tags/link_tag'

require 'support/contracts/data/see_tag_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::SeeTags::LinkTag do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:see_tag) { described_class.new(native:, parent:) }

  include_context 'with fixture files', 'see_tags'

  let(:fixture) { 'link.rb' }
  let(:parent)  { YARD::Registry.find { |obj| obj.title == 'Space' } }
  let(:native)  { parent.tags.find { |tag| tag.tag_name == 'see' } }

  include_contract 'should be a see tag object',
    expected_json: lambda {
      {
        'label' => 'https://www.example.com',
        'path'  => 'https://www.example.com',
        'text'  => nil,
        'type'  => 'link'
      }
    }

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
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'instance method' do
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'link with text' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'plain text' do
      it { expect(described_class.match?(native)).to be false }
    end
  end

  describe '#as_json' do
    wrap_context 'using fixture', 'link with text' do
      let(:expected) do
        {
          'label' => 'https://www.example.com',
          'path'  => 'https://www.example.com',
          'text'  => 'This is a link to example.com.',
          'type'  => 'link'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end
  end

  describe '#label' do
    let(:expected) { 'https://www.example.com' }

    include_examples 'should define reader', :label, -> { expected }

    wrap_context 'using fixture', 'link with text' do
      it { expect(see_tag.label).to be == expected }
    end
  end

  describe '#path' do
    let(:expected) { 'https://www.example.com' }

    include_examples 'should define reader', :path, -> { expected }

    wrap_context 'using fixture', 'link with text' do
      it { expect(see_tag.path).to be == expected }
    end
  end

  describe '#text' do
    include_examples 'should define reader', :text, nil

    wrap_context 'using fixture', 'link with text' do
      let(:expected) { 'This is a link to example.com.' }

      it { expect(see_tag.text).to be == expected }
    end
  end

  describe '#text?' do
    include_examples 'should define predicate', :text?, false

    wrap_context 'using fixture', 'link with text' do
      it { expect(see_tag.text?).to be true }
    end
  end
end
