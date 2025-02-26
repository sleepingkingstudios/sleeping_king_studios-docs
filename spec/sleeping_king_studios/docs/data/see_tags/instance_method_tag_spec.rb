# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/see_tags/instance_method_tag'

require 'support/contracts/data/see_tag_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Docs::Data::SeeTags::InstanceMethodTag do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:see_tag) { described_class.new(native:, parent:) }

  include_context 'with fixture files', 'see_tags'

  let(:fixture) { 'instance_method.rb' }
  let(:parent)  { YARD::Registry.find { |obj| obj.title == 'Space' } }
  let(:native)  { parent.tags.find { |tag| tag.tag_name == 'see' } }

  include_contract 'should be a see tag object',
    expected_json: lambda {
      {
        'label' => '#launch_rocket',
        'path'  => '#instance-method-launch-rocket',
        'text'  => nil,
        'type'  => 'reference'
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

    wrap_context 'using fixture', 'instance attribute reader' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'instance attribute writer' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'instance method predicate' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'instance method writer' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'instance method with text' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'link' do
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'nested instance method' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'plain text' do
      it { expect(described_class.match?(native)).to be false }
    end

    wrap_context 'using fixture', 'relative instance method' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'scoped instance method' do
      it { expect(described_class.match?(native)).to be true }
    end

    wrap_context 'using fixture', 'unmatched instance method' do
      it { expect(described_class.match?(native)).to be true }
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'label' => '#launch_rocket',
        'path'  => '#instance-method-launch-rocket',
        'text'  => nil,
        'type'  => 'reference'
      }
    end

    wrap_context 'using fixture', 'instance attribute reader' do
      let(:expected) do
        super().merge(
          'label' => '#rocket_launched',
          'path'  => '#instance-attribute-rocket-launched'
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'instance attribute writer' do
      let(:expected) do
        super().merge(
          'label' => '#rocket_launched=',
          'path'  => '#instance-attribute-rocket-launched='
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'instance method predicate' do
      let(:expected) do
        super().merge(
          'label' => '#rocket_launched?',
          'path'  => '#instance-method-rocket-launched?'
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'instance method writer' do
      let(:expected) do
        super().merge(
          'label' => '#rocket_launched=',
          'path'  => '#instance-method-rocket-launched='
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'instance method with text' do
      let(:expected) do
        super().merge('text' => 'You are going to space today!')
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'nested instance method' do
      let(:expected_path) do
        'simulation/testing/space-program#instance-method-launch-rocket'
      end
      let(:expected) do
        super().merge(
          'label' => 'Simulation::Testing::SpaceProgram#launch_rocket',
          'path'  => expected_path
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'relative instance method' do
      let(:expected) do
        super().merge(
          'label' => 'SpaceProgram#launch_rocket',
          'path'  => 'space/space-program#instance-method-launch-rocket'
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'scoped instance method' do
      let(:expected) do
        super().merge(
          'label' => 'SpaceProgram#launch_rocket',
          'path'  => 'space-program#instance-method-launch-rocket'
        )
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched instance method' do
      let(:expected) { super().merge('path' => nil) }

      it { expect(see_tag.as_json).to be == expected }
    end
  end

  describe '#attribute?' do
    include_examples 'should define predicate', :attribute?, false

    wrap_context 'using fixture', 'instance attribute reader' do
      it { expect(see_tag.attribute?).to be true }
    end

    wrap_context 'using fixture', 'instance attribute writer' do
      it { expect(see_tag.attribute?).to be true }
    end

    wrap_context 'using fixture', 'instance method predicate' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'instance method writer' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'instance method with text' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'nested instance method' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'relative instance method' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'scoped instance method' do
      it { expect(see_tag.attribute?).to be false }
    end

    wrap_context 'using fixture', 'unmatched instance method' do
      it { expect(see_tag.attribute?).to be false }
    end
  end

  describe '#exists?' do
    include_examples 'should define predicate', :exists?, true

    wrap_context 'using fixture', 'instance attribute reader' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'instance attribute writer' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'instance method predicate' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'instance method writer' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'instance method with text' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'nested instance method' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'relative instance method' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'scoped instance method' do
      it { expect(see_tag.exists?).to be true }
    end

    wrap_context 'using fixture', 'unmatched instance method' do
      it { expect(see_tag.exists?).to be false }
    end
  end

  describe '#local?' do
    include_examples 'should define predicate', :local?, true

    wrap_context 'using fixture', 'instance attribute reader' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'instance attribute writer' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'instance method predicate' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'instance method writer' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'instance method with text' do
      it { expect(see_tag.local?).to be true }
    end

    wrap_context 'using fixture', 'nested instance method' do
      it { expect(see_tag.local?).to be false }
    end

    wrap_context 'using fixture', 'relative instance method' do
      it { expect(see_tag.local?).to be false }
    end

    wrap_context 'using fixture', 'scoped instance method' do
      it { expect(see_tag.local?).to be false }
    end

    wrap_context 'using fixture', 'unmatched instance method' do
      it { expect(see_tag.local?).to be false }
    end
  end

  describe '#path' do
    let(:expected) { '#instance-method-launch-rocket' }

    include_examples 'should define reader', :path, -> { expected }

    wrap_context 'using fixture', 'instance attribute reader' do
      let(:expected) { '#instance-attribute-rocket-launched' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'instance attribute writer' do
      let(:expected) { '#instance-attribute-rocket-launched=' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'instance method predicate' do
      let(:expected) { '#instance-method-rocket-launched?' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'instance method writer' do
      let(:expected) { '#instance-method-rocket-launched=' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'instance method with text' do
      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'nested instance method' do
      let(:expected) do
        'simulation/testing/space-program#instance-method-launch-rocket'
      end

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'relative instance method' do
      let(:expected) { 'space/space-program#instance-method-launch-rocket' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'scoped instance method' do
      let(:expected) { 'space-program#instance-method-launch-rocket' }

      it { expect(see_tag.path).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched instance method' do
      it { expect(see_tag.path).to be nil }
    end
  end

  describe '#reference' do
    include_examples 'should define reader', :reference, '#launch_rocket'

    wrap_context 'using fixture', 'instance attribute reader' do
      it { expect(see_tag.reference).to be == '#rocket_launched' }
    end

    wrap_context 'using fixture', 'instance attribute writer' do
      it { expect(see_tag.reference).to be == '#rocket_launched=' }
    end

    wrap_context 'using fixture', 'instance method predicate' do
      it { expect(see_tag.reference).to be == '#rocket_launched?' }
    end

    wrap_context 'using fixture', 'instance method writer' do
      it { expect(see_tag.reference).to be == '#rocket_launched=' }
    end

    wrap_context 'using fixture', 'instance method with text' do
      it { expect(see_tag.reference).to be == '#launch_rocket' }
    end

    wrap_context 'using fixture', 'nested instance method' do
      let(:expected) do
        'Simulation::Testing::SpaceProgram#launch_rocket'
      end

      it { expect(see_tag.reference).to be == expected }
    end

    wrap_context 'using fixture', 'relative instance method' do
      it { expect(see_tag.reference).to be == 'SpaceProgram#launch_rocket' }
    end

    wrap_context 'using fixture', 'scoped instance method' do
      it { expect(see_tag.reference).to be == 'SpaceProgram#launch_rocket' }
    end

    wrap_context 'using fixture', 'unmatched instance method' do
      it { expect(see_tag.reference).to be == '#launch_rocket' }
    end
  end

  describe '#text' do
    include_examples 'should define reader', :text, nil

    wrap_context 'using fixture', 'instance method with text' do
      let(:expected) { 'You are going to space today!' }

      it { expect(see_tag.text).to be == expected }
    end
  end

  describe '#text?' do
    include_examples 'should define predicate', :text?, false

    wrap_context 'using fixture', 'instance method with text' do
      it { expect(see_tag.text?).to be true }
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, 'instance-method'

    wrap_context 'using fixture', 'instance attribute reader' do
      it { expect(see_tag.type).to be == 'instance-attribute' }
    end
  end
end
