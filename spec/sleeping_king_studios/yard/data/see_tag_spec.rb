# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tag'

require 'support/contracts/data/base_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::SeeTag do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:see_tag) do
    described_class.new(native: native, registry: ::YARD::Registry)
  end

  include_context 'with fixture files', 'metadata/see'

  let(:fixture) { 'plain_text.rb' }
  let(:native) do
    YARD::Registry
      .find { |obj| obj.title == 'Space' }
      .tags
      .find { |tag| tag.tag_name == 'see' }
  end

  include_contract 'should be a data object',
    expected_json: -> { { 'text' => see_tag.text } }

  describe '#as_json' do
    wrap_context 'using fixture', 'class method' do
      let(:expected) do
        {
          'text'         => see_tag.text,
          'type'         => 'class_method',
          'path'         => '',
          'class_method' => 'reboot-cosmos'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'class method with text' do
      let(:expected) do
        {
          'text'         => see_tag.text,
          'type'         => 'class_method',
          'path'         => '',
          'class_method' => 'reboot-cosmos'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'constant' do
      let(:expected) do
        {
          'text'     => see_tag.text,
          'type'     => 'constant',
          'path'     => '',
          'constant' => 'gravity'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'definition' do
      let(:expected) do
        {
          'text' => see_tag.text,
          'type' => 'definition',
          'path' => 'time'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'definition with text' do
      let(:expected) do
        {
          'text' => see_tag.text,
          'type' => 'definition',
          'path' => 'time'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'instance method' do
      let(:expected) do
        {
          'text'            => see_tag.text,
          'type'            => 'instance_method',
          'path'            => '',
          'instance_method' => 'launch-rocket'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'instance method with text' do
      let(:expected) do
        {
          'text'            => see_tag.text,
          'type'            => 'instance_method',
          'path'            => '',
          'instance_method' => 'launch-rocket'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'link' do
      let(:expected) do
        {
          'link' => see_tag.reference,
          'text' => see_tag.text
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'link with text' do
      let(:expected) do
        {
          'link' => see_tag.reference,
          'text' => see_tag.text
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'scoped class method' do
      let(:expected) do
        {
          'text'         => see_tag.text,
          'type'         => 'class_method',
          'path'         => 'cosmos',
          'class_method' => 'reboot-cosmos'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'scoped constant' do
      let(:expected) do
        {
          'text'     => see_tag.text,
          'type'     => 'constant',
          'path'     => 'cosmos',
          'constant' => 'gravity'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'scoped definition' do
      let(:expected) do
        {
          'text' => see_tag.text,
          'type' => 'definition',
          'path' => 'cosmos--spiral-galaxy'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'scoped definition with text' do
      let(:expected) do
        {
          'text' => see_tag.text,
          'type' => 'definition',
          'path' => 'cosmos--spiral-galaxy'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'scoped instance method' do
      let(:expected) do
        {
          'text'            => see_tag.text,
          'type'            => 'instance_method',
          'path'            => 'space-program',
          'instance_method' => 'launch-rocket'
        }
      end

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched class method' do
      let(:expected) { { 'text' => see_tag.text } }

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched constant' do
      let(:expected) { { 'text' => see_tag.text } }

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched definition' do
      let(:expected) { { 'text' => see_tag.text } }

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched definition with text' do
      let(:expected) { { 'text' => see_tag.text } }

      it { expect(see_tag.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched instance method' do
      let(:expected) { { 'text' => see_tag.text } }

      it { expect(see_tag.as_json).to be == expected }
    end
  end

  describe '#link?' do
    include_examples 'should define predicate', :link?, false

    wrap_context 'using fixture', 'definition' do
      it { expect(see_tag.link?).to be false }
    end

    wrap_context 'using fixture', 'link' do
      it { expect(see_tag.link?).to be true }
    end

    wrap_context 'using fixture', 'unmatched definition' do
      it { expect(see_tag.link?).to be false }
    end
  end

  describe '#plain_text?' do
    include_examples 'should define predicate', :plain_text?, true

    wrap_context 'using fixture', 'definition' do
      it { expect(see_tag.plain_text?).to be false }
    end

    wrap_context 'using fixture', 'link' do
      it { expect(see_tag.plain_text?).to be false }
    end

    wrap_context 'using fixture', 'unmatched definition' do
      it { expect(see_tag.plain_text?).to be false }
    end
  end

  describe '#reference' do
    include_examples 'should define reader', :reference, '_'

    wrap_context 'using fixture', 'class method' do
      it { expect(see_tag.reference).to be == '.reboot_cosmos' }
    end

    wrap_context 'using fixture', 'definition' do
      it { expect(see_tag.reference).to be == 'Time' }
    end

    wrap_context 'using fixture', 'link' do
      it { expect(see_tag.reference).to be == 'https://www.example.com' }
    end

    wrap_context 'using fixture', 'scoped class method' do
      it { expect(see_tag.reference).to be == 'Cosmos.reboot_cosmos' }
    end

    wrap_context 'using fixture', 'scoped definition' do
      it { expect(see_tag.reference).to be == 'Cosmos::SpiralGalaxy' }
    end

    wrap_context 'using fixture', 'unmatched definition' do
      it { expect(see_tag.reference).to be == 'String' }
    end
  end

  describe '#reference?' do
    include_examples 'should define predicate', :reference?, false

    wrap_context 'using fixture', 'definition' do
      it { expect(see_tag.reference?).to be true }
    end

    wrap_context 'using fixture', 'link' do
      it { expect(see_tag.reference?).to be false }
    end

    wrap_context 'using fixture', 'unmatched definition' do
      it { expect(see_tag.reference?).to be true }
    end
  end

  describe '#reference_type' do
    include_examples 'should define reader', :reference_type, nil

    wrap_context 'using fixture', 'class method' do
      it { expect(see_tag.reference_type).to be :class_method }
    end

    wrap_context 'using fixture', 'constant' do
      it { expect(see_tag.reference_type).to be :constant }
    end

    wrap_context 'using fixture', 'definition' do
      it { expect(see_tag.reference_type).to be :definition }
    end

    wrap_context 'using fixture', 'instance method' do
      it { expect(see_tag.reference_type).to be :instance_method }
    end

    wrap_context 'using fixture', 'scoped class method' do
      it { expect(see_tag.reference_type).to be :class_method }
    end

    wrap_context 'using fixture', 'scoped class method with semicolons' do
      it { expect(see_tag.reference_type).to be :class_method }
    end

    wrap_context 'using fixture', 'scoped constant' do
      it { expect(see_tag.reference_type).to be :constant }
    end

    wrap_context 'using fixture', 'scoped definition' do
      it { expect(see_tag.reference_type).to be :definition }
    end

    wrap_context 'using fixture', 'scoped instance method' do
      it { expect(see_tag.reference_type).to be :instance_method }
    end

    wrap_context 'using fixture', 'unmatched class method' do
      it { expect(see_tag.reference_type).to be nil }
    end

    wrap_context 'using fixture', 'unmatched constant' do
      it { expect(see_tag.reference_type).to be nil }
    end

    wrap_context 'using fixture', 'unmatched definition' do
      it { expect(see_tag.reference_type).to be nil }
    end

    wrap_context 'using fixture', 'unmatched instance method' do
      it { expect(see_tag.reference_type).to be nil }
    end
  end

  describe '#text' do
    let(:expected) { 'This is a plain text message.' }

    include_examples 'should define reader', :text, -> { expected }

    wrap_context 'using fixture', 'definition' do
      it { expect(see_tag.text).to be == 'Time' }
    end

    wrap_context 'using fixture', 'definition with text' do
      let(:expected) { 'The Time module.' }

      it { expect(see_tag.text).to be == expected }
    end

    wrap_context 'using fixture', 'link' do
      it { expect(see_tag.text).to be == 'https://www.example.com' }
    end

    wrap_context 'using fixture', 'link with text' do
      let(:expected) { 'This is a link to example.com.' }

      it { expect(see_tag.text).to be == expected }
    end

    wrap_context 'using fixture', 'scoped definition' do
      it { expect(see_tag.text).to be == 'Cosmos::SpiralGalaxy' }
    end

    wrap_context 'using fixture', 'scoped definition with text' do
      let(:expected) { 'The prettiest galaxy, barred none.' }

      it { expect(see_tag.text).to be == expected }
    end

    wrap_context 'using fixture', 'unmatched definition' do
      it { expect(see_tag.text).to be == 'String' }
    end

    wrap_context 'using fixture', 'unmatched definition with text' do
      let(:expected) { 'The native String class.' }

      it { expect(see_tag.text).to be == expected }
    end
  end

  describe '#text?' do
    include_examples 'should define predicate', :text?, true

    wrap_context 'using fixture', 'definition' do
      it { expect(see_tag.text?).to be false }
    end

    wrap_context 'using fixture', 'definition with text' do
      it { expect(see_tag.text?).to be true }
    end

    wrap_context 'using fixture', 'link' do
      it { expect(see_tag.text?).to be false }
    end

    wrap_context 'using fixture', 'link with text' do
      it { expect(see_tag.text?).to be true }
    end

    wrap_context 'using fixture', 'scoped definition' do
      it { expect(see_tag.text?).to be false }
    end

    wrap_context 'using fixture', 'scoped definition with text' do
      it { expect(see_tag.text?).to be true }
    end

    wrap_context 'using fixture', 'unmatched definition' do
      it { expect(see_tag.text?).to be false }
    end

    wrap_context 'using fixture', 'unmatched definition with text' do
      it { expect(see_tag.text?).to be true }
    end
  end
end
