# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tags/reference_tag'

require 'support/contracts/data/see_tag_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::SeeTags::ReferenceTag do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:see_tag) { described_class.new(native: native, parent: parent) }

  include_context 'with fixture files', 'see_tags'

  let(:fixture) { 'definition.rb' }
  let(:parent)  { YARD::Registry.find { |obj| obj.title == 'Space' } }
  let(:native)  { parent.tags.find { |tag| tag.tag_name == 'see' } }

  include_contract 'should be a see tag object',
    expected_json: lambda {
      {
        'label' => 'Time',
        'path'  => nil,
        'text'  => nil,
        'type'  => 'reference'
      }
    }

  describe '#as_json' do
    let(:expected) do
      {
        'label' => 'Time',
        'path'  => nil,
        'text'  => nil,
        'type'  => 'reference'
      }
    end

    wrap_context 'using fixture', 'definition with text' do
      let(:expected) do
        super().merge('text' => 'The Time module.')
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'nested definition' do
      let(:expected) do
        super().merge('label' => 'Simulation::Testing::Cosmos::SpiralGalaxy')
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'relative definition' do
      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'scoped definition' do
      let(:expected) do
        super().merge('label' => 'Cosmos::SpiralGalaxy')
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched definition' do
      let(:expected) do
        super().merge('label' => 'String')
      end

      it { expect(see_tag.as_json).to be == expected }
    end
  end

  describe '#exists?' do
    include_examples 'should define predicate', :exists?, false

    wrap_context 'using fixture', 'definition with text' do
      it { expect(see_tag.exists?).to be false }
    end

    wrap_context 'using fixture', 'nested definition' do
      it { expect(see_tag.exists?).to be false }
    end

    wrap_context 'using fixture', 'relative definition' do
      it { expect(see_tag.exists?).to be false }
    end

    wrap_context 'using fixture', 'scoped definition' do
      it { expect(see_tag.exists?).to be false }
    end

    wrap_context 'using fixture', 'unmatched definition' do
      it { expect(see_tag.exists?).to be false }
    end
  end

  describe '#path' do
    include_examples 'should define reader', :path, nil

    wrap_context 'using fixture', 'definition with text' do
      it { expect(see_tag.path).to be nil }
    end

    wrap_context 'using fixture', 'nested definition' do
      it { expect(see_tag.path).to be nil }
    end

    wrap_context 'using fixture', 'scoped definition' do
      it { expect(see_tag.path).to be nil }
    end

    wrap_context 'using fixture', 'unmatched definition' do
      it { expect(see_tag.path).to be nil }
    end
  end

  describe '#reference' do
    include_examples 'should define reader', :reference, 'Time'

    it { expect(see_tag).to have_aliased_method(:reference).as(:label) }

    wrap_context 'using fixture', 'definition with text' do
      it { expect(see_tag.reference).to be == 'Time' }
    end

    wrap_context 'using fixture', 'nested definition' do
      let(:expected) { 'Simulation::Testing::Cosmos::SpiralGalaxy' }

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'relative definition' do
      it { expect(see_tag.reference).to be == 'Time' }
    end

    wrap_context 'using fixture', 'scoped definition' do
      it { expect(see_tag.reference).to be == 'Cosmos::SpiralGalaxy' }
    end

    wrap_context 'using fixture', 'unmatched definition' do
      it { expect(see_tag.reference).to be == 'String' }
    end
  end

  describe '#text' do
    include_examples 'should define reader', :text, nil

    wrap_context 'using fixture', 'definition with text' do
      let(:expected) { 'The Time module.' }

      it { expect(see_tag.text).to be == expected }
    end
  end

  describe '#text?' do
    include_examples 'should define predicate', :text?, false

    wrap_context 'using fixture', 'definition with text' do
      it { expect(see_tag.text?).to be true }
    end
  end
end
