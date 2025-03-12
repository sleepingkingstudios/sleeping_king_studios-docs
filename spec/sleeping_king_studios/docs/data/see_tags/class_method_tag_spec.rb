# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/see_tags/class_method_tag'

require 'support/contracts/data/see_tag_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Docs::Data::SeeTags::ClassMethodTag do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:see_tag) { described_class.new(native:, parent:) }

  include_context 'with fixture files', 'see_tags'

  let(:fixture) { 'class_method.rb' }
  let(:parent)  { YARD::Registry.find { |obj| obj.title == 'Space' } }
  let(:native)  { parent.tags.find { |tag| tag.tag_name == 'see' } }

  include_contract 'should be a see tag object',
    expected_json: lambda {
      {
        'label' => '.reboot_cosmos',
        'path'  => '#class-method-reboot-cosmos',
        'text'  => nil,
        'type'  => 'reference'
      }
    }

  describe '.match?' do
    it { expect(described_class).to respond_to(:match?).with(1).argument }

    it { expect(described_class).to have_aliased_method(:match?).as(:matches?) }

    it { expect(described_class.match?(native)).to be true }

    wrap_context 'using fixture', 'class attribute reader' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'class attribute writer' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'class method operator' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'class method predicate' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'class method writer' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'class method with text' do
      it { expect(described_class.match?(native)).to be true }
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

    wrap_context 'using fixture', 'legacy class method' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'link' do
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'nested class method' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'plain text' do
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'relative class method' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'scoped class method' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'unmatched class method' do
      it { expect(described_class.match?(native)).to be true }
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'label' => '.reboot_cosmos',
        'path'  => '#class-method-reboot-cosmos',
        'text'  => nil,
        'type'  => 'reference'
      }
    end

    wrap_context 'using fixture', 'class attribute reader' do
      let(:expected) do
        super().merge(
          'label' => '.curvature',
          'path'  => '#class-attribute-curvature'
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'class attribute writer' do
      let(:expected) do
        super().merge(
          'label' => '.curvature=',
          'path'  => '#class-attribute-curvature='
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'class method operator' do
      let(:expected) do
        super().merge(
          'label' => '.[]=',
          'path'  => '#class-method-[]='
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'class method predicate' do
      let(:expected) do
        super().merge(
          'label' => '.cosmos_rebooted?',
          'path'  => '#class-method-cosmos-rebooted?'
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'class method writer' do
      let(:expected) do
        super().merge(
          'label' => '.cosmos_version=',
          'path'  => '#class-method-cosmos-version='
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'class method with text' do
      let(:expected) do
        super().merge('text' => 'Have you tried turning it off and on again?')
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'legacy class method' do
      let(:expected) do
        super().merge('label' => '::reboot_cosmos')
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'nested class method' do
      let(:expected) do
        super().merge(
          'label' => 'Simulation::Testing::Cosmos.reboot_cosmos',
          'path'  => 'simulation/testing/cosmos#class-method-reboot-cosmos'
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'relative class method' do
      let(:expected) do
        super().merge(
          'label' => 'Time.reboot_cosmos',
          'path'  => 'space/time#class-method-reboot-cosmos'
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'scoped class method' do
      let(:expected) do
        super().merge(
          'label' => 'Cosmos.reboot_cosmos',
          'path'  => 'cosmos#class-method-reboot-cosmos'
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched class method' do
      let(:expected) do
        super().merge('path' => nil)
      end

      it { expect(see_tag.as_json).to be == expected }
    end
  end

  describe '#attribute?' do
    include_examples 'should define predicate', :attribute?, false

    wrap_context 'using fixture', 'class attribute reader' do
      it { expect(see_tag.attribute?).to be true }
    end

    wrap_context 'using fixture', 'class attribute writer' do
      it { expect(see_tag.attribute?).to be true }
    end

    wrap_context 'using fixture', 'class method operator' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'class method predicate' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'class method writer' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'class method with text' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'legacy class method' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'nested class method' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'relative class method' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'scoped class method' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'unmatched class method' do
      it { expect(see_tag.attribute?).to be false }
    end
  end

  describe '#exists?' do
    include_examples 'should define predicate', :exists?, true

    wrap_context 'using fixture', 'class attribute reader' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'class attribute writer' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'class method operator' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'class method predicate' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'class method writer' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'class method with text' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'legacy class method' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'nested class method' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'relative class method' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'scoped class method' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'unmatched class method' do
      it { expect(see_tag.exists?).to be false }
    end
  end

  describe '#local?' do
    include_examples 'should define predicate', :local?, true

    wrap_context 'using fixture', 'class attribute reader' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'class attribute writer' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'class method operator' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'class method predicate' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'class method writer' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'class method with text' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'legacy class method' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'nested class method' do
      it { expect(see_tag.local?).to be false }
    end

    wrap_context 'using fixture', 'relative class method' do
      it { expect(see_tag.local?).to be false }
    end

    wrap_context 'using fixture', 'scoped class method' do
      it { expect(see_tag.local?).to be false }
    end

    wrap_context 'using fixture', 'unmatched class method' do
      it { expect(see_tag.local?).to be false }
    end
  end

  describe '#path' do
    let(:expected) { '#class-method-reboot-cosmos' }

    include_examples 'should define reader', :path, -> { expected }

    wrap_context 'using fixture', 'class attribute reader' do
      let(:expected) { '#class-attribute-curvature' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'class attribute writer' do
      let(:expected) { '#class-attribute-curvature=' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'class method operator' do
      let(:expected) { '#class-method-[]=' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'class method predicate' do
      let(:expected) { '#class-method-cosmos-rebooted?' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'class method writer' do
      let(:expected) { '#class-method-cosmos-version=' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'class method with text' do
      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'legacy class method' do
      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'nested class method' do
      let(:expected) do
        'simulation/testing/cosmos#class-method-reboot-cosmos'
      end

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'relative class method' do
      let(:expected) do
        'space/time#class-method-reboot-cosmos'
      end

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'scoped class method' do
      let(:expected) do
        'cosmos#class-method-reboot-cosmos'
      end

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched class method' do
      it { expect(see_tag.path).to be nil }
    end
  end

  describe '#reference' do
    include_examples 'should define reader', :reference, '.reboot_cosmos'

    wrap_context 'using fixture', 'class attribute reader' do
      let(:expected) { '.curvature' }

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'class attribute writer' do
      let(:expected) { '.curvature=' }

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'class method operator' do
      let(:expected) { '.[]=' }

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'class method predicate' do
      let(:expected) { '.cosmos_rebooted?' }

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'class method writer' do
      let(:expected) { '.cosmos_version=' }

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'class method with text' do
      it { expect(see_tag.reference).to be == '.reboot_cosmos' }
    end

    wrap_context 'using fixture', 'legacy class method' do
      it { expect(see_tag.reference).to be == '::reboot_cosmos' }
    end

    wrap_context 'using fixture', 'nested class method' do
      let(:expected) do
        'Simulation::Testing::Cosmos.reboot_cosmos'
      end

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'relative class method' do
      let(:expected) do
        'Time.reboot_cosmos'
      end

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'scoped class method' do
      let(:expected) do
        'Cosmos.reboot_cosmos'
      end

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched class method' do
      it { expect(see_tag.reference).to be == '.reboot_cosmos' }
    end
  end

  describe '#text' do
    include_examples 'should define reader', :text, nil

    wrap_context 'using fixture', 'class method with text' do
      let(:expected) { 'Have you tried turning it off and on again?' }

      it { expect(see_tag.text).to be == expected }
    end
  end

  describe '#text?' do
    include_examples 'should define predicate', :text?, false

    wrap_context 'using fixture', 'class method with text' do
      it { expect(see_tag.text?).to be true }
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, 'class-method'

    wrap_context 'using fixture', 'class attribute reader' do
      it { expect(see_tag.type).to be == 'class-attribute' }
    end
  end
end
