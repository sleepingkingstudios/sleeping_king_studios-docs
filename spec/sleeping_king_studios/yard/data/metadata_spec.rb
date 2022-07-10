# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/metadata'

require 'support/contracts/data/base_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::Metadata do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:metadata) do
    described_class.new(native: native, registry: ::YARD::Registry)
  end

  include_context 'with fixture files', 'metadata'

  let(:fixture) { 'none.rb' }
  let(:native)  { YARD::Registry.find { |obj| obj.title == 'Space' } }

  def format_see_tag(tag)
    SleepingKingStudios::Yard::Data::SeeTag
      .new(native: tag, registry: ::YARD::Registry)
      .as_json
  end

  include_contract 'should be a data object'

  describe '#as_json' do
    wrap_context 'using fixture', 'with examples' do
      let(:expected) { { 'examples' => metadata.examples } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with notes' do
      let(:expected) { { 'notes' => metadata.notes } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with see' do
      let(:expected) { { 'see' => metadata.see } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with todos' do
      let(:expected) { { 'todos' => metadata.todos } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        {
          'examples' => metadata.examples,
          'notes'    => metadata.notes,
          'see'      => metadata.see,
          'todos'    => metadata.todos
        }
      end

      it { expect(metadata.as_json).to be == expected }
    end
  end

  describe '#examples' do
    include_examples 'should define reader', :examples, []

    wrap_context 'using fixture', 'with examples' do
      let(:expected) do
        [
          {
            'name' => '',
            'text' => '# This is an anonymous example.'
          },
          {
            'name' => '',
            'text' => '# This is another anonymous example.'
          },
          {
            'name' => 'Named Example',
            'text' => '# This is a named example.'
          }
        ]
      end

      it { expect(metadata.examples).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'name' => '',
            'text' => '# This is an anonymous example.'
          },
          {
            'name' => '',
            'text' => '# This is another anonymous example.'
          },
          {
            'name' => 'Named Example',
            'text' => '# This is a named example.'
          }
        ]
      end

      it { expect(metadata.examples).to be == expected }
    end
  end

  describe '#notes' do
    include_examples 'should define reader', :notes, []

    wrap_context 'using fixture', 'with notes' do
      let(:expected) do
        [
          'This is a note.',
          'This is another note.',
          'This makes a chord.'
        ]
      end

      it { expect(metadata.notes).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          'This is a note.',
          'This is another note.',
          'This makes a chord.'
        ]
      end

      it { expect(metadata.notes).to be == expected }
    end
  end

  describe '#see' do
    include_examples 'should define reader', :see, []

    wrap_context 'using fixture', 'with see' do
      let(:expected) do
        native
          .tags
          .select { |tag| tag.tag_name == 'see' }
          .map { |tag| format_see_tag(tag) }
      end

      it { expect(metadata.see).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        native
          .tags
          .select { |tag| tag.tag_name == 'see' }
          .map { |tag| format_see_tag(tag) }
      end

      it { expect(metadata.see).to be == expected }
    end
  end

  describe '#todos' do
    include_examples 'should define reader', :todos, []

    wrap_context 'using fixture', 'with todos' do
      let(:expected) do
        [
          'Cut the blue wire.',
          'Cut the red wire.',
          'Remove the plutonium.'
        ]
      end

      it { expect(metadata.todos).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          'Cut the blue wire.',
          'Cut the red wire.',
          'Remove the plutonium.'
        ]
      end

      it { expect(metadata.todos).to be == expected }
    end
  end
end
