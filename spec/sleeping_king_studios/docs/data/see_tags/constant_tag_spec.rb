# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/see_tags/constant_tag'

require 'support/contracts/data/see_tag_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Docs::Data::SeeTags::ConstantTag do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:see_tag) { described_class.new(native:, parent:) }

  include_context 'with fixture files', 'see_tags'

  let(:fixture) { 'constant.rb' }
  let(:parent)  { YARD::Registry.find { |obj| obj.title == 'Space' } }
  let(:native)  { parent.tags.find { |tag| tag.tag_name == 'see' } }

  include_contract 'should be a see tag object',
    expected_json: lambda {
      {
        'label' => 'GRAVITY',
        'path'  => '#constant-gravity',
        'text'  => nil,
        'type'  => 'reference'
      }
    }

  describe '.match?' do
    it { expect(described_class).to respond_to(:match?).with(1).argument }

    it { expect(described_class).to have_aliased_method(:match?).as(:matches?) }

    it { expect(described_class.match?(native)).to be true }

    wrap_context 'using fixture', 'absolute constant' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'class method' do
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'constant with text' do
      it { expect(described_class.match?(native)).to be true }
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

    wrap_context 'using fixture', 'link' do
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'nested constant' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'plain text' do
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'relative constant' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'scoped constant' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'unmatched constant' do
      it { expect(described_class.match?(native)).to be true }
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'label' => 'GRAVITY',
        'path'  => '#constant-gravity',
        'text'  => nil,
        'type'  => 'reference'
      }
    end

    wrap_context 'using fixture', 'absolute constant' do
      let(:expected) { super().merge('path' => '/#constant-gravity') }

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'constant with text' do
      let(:expected) do
        super().merge('text' => 'Acceleration due to gravity.')
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'nested constant' do
      let(:expected) do
        super().merge(
          'label' => 'Simulation::Testing::Cosmos::GRAVITY',
          'path'  => 'simulation/testing/cosmos#constant-gravity'
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'relative constant' do
      let(:expected) do
        super().merge(
          'label' => 'Physics::GRAVITY',
          'path'  => 'space/physics#constant-gravity'
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'scoped constant' do
      let(:expected) do
        super().merge(
          'label' => 'Cosmos::GRAVITY',
          'path'  => 'cosmos#constant-gravity'
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched constant' do
      let(:expected) { super().merge('path' => nil) }

      it { expect(see_tag.as_json).to be == expected }
    end
  end

  describe '#exists?' do
    include_examples 'should define predicate', :exists?, true

    wrap_context 'using fixture', 'absolute constant' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'constant with text' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'nested constant' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'relative constant' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'scoped constant' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'unmatched constant' do
      it { expect(see_tag.exists?).to be false }
    end
  end

  describe '#local?' do
    include_examples 'should define predicate', :local?, true

    wrap_context 'using fixture', 'absolute constant' do
      it { expect(see_tag.local?).to be false }
    end

    wrap_context 'using fixture', 'constant with text' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'nested constant' do
      it { expect(see_tag.local?).to be false }
    end

    wrap_context 'using fixture', 'relative constant' do
      it { expect(see_tag.local?).to be false }
    end

    wrap_context 'using fixture', 'scoped constant' do
      it { expect(see_tag.local?).to be false }
    end

    wrap_context 'using fixture', 'unmatched constant' do
      it { expect(see_tag.local?).to be false }
    end
  end

  describe '#path' do
    let(:expected) { '#constant-gravity' }

    include_examples 'should define reader', :path, -> { expected }

    wrap_context 'using fixture', 'absolute constant' do
      let(:expected) { '/#constant-gravity' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'constant with text' do
      let(:expected) { '#constant-gravity' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'nested constant' do
      let(:expected) { 'simulation/testing/cosmos#constant-gravity' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'relative constant' do
      let(:expected) { 'space/physics#constant-gravity' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'scoped constant' do
      let(:expected) { 'cosmos#constant-gravity' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched constant' do
      it { expect(see_tag.path).to be nil }
    end
  end

  describe '#reference' do
    include_examples 'should define reader', :reference, 'GRAVITY'

    wrap_context 'using fixture', 'absolute constant' do
      it { expect(see_tag.reference).to be == 'GRAVITY' }
    end

    wrap_context 'using fixture', 'constant with text' do
      it { expect(see_tag.reference).to be == 'GRAVITY' }
    end

    wrap_context 'using fixture', 'nested constant' do
      let(:expected) { 'Simulation::Testing::Cosmos::GRAVITY' }

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'relative constant' do
      let(:expected) { 'Physics::GRAVITY' }

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'scoped constant' do
      let(:expected) { 'Cosmos::GRAVITY' }

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched constant' do
      let(:expected) { 'GRAVITY' }

      it { expect(see_tag.reference).to be == expected }
    end
  end

  describe '#text' do
    include_examples 'should define reader', :text, nil

    wrap_context 'using fixture', 'constant with text' do
      let(:expected) { 'Acceleration due to gravity.' }

      it { expect(see_tag.text).to be == expected }
    end
  end

  describe '#text?' do
    include_examples 'should define predicate', :text?, false

    wrap_context 'using fixture', 'constant with text' do
      it { expect(see_tag.text?).to be true }
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, 'constant'
  end
end
