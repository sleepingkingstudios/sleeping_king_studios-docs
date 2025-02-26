# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/metadata'

require 'support/contracts/data/base_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::Metadata do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:metadata) { described_class.new(native:) }

  include_context 'with fixture files', 'metadata'

  let(:fixture) { 'none.rb' }
  let(:native)  { YARD::Registry.find { |obj| obj.title == 'Space' } }

  def format_see_tag(tag)
    SleepingKingStudios::Docs::Data::SeeTags
      .build(native: tag, parent: native)
      .as_json
  end

  include_contract 'should be a data object'

  describe '#abstract' do
    include_examples 'should define reader', :abstract, nil

    wrap_context 'using fixture', 'with abstract' do
      it { expect(metadata.abstract).to be == '' }
    end

    wrap_context 'using fixture', 'with abstract with text' do
      it { expect(metadata.abstract).to be == 'Also requires Time.' }
    end

    wrap_context 'using fixture', 'with everything' do
      it { expect(metadata.abstract).to be == 'Also requires Time.' }
    end
  end

  describe '#api' do
    include_examples 'should define reader', :api, nil

    wrap_context 'using fixture', 'with api' do
      it { expect(metadata.api).to be == 'internal' }
    end

    wrap_context 'using fixture', 'with api private' do
      it { expect(metadata.api).to be == 'private' }
    end

    wrap_context 'using fixture', 'with everything' do
      it { expect(metadata.api).to be == 'internal' }
    end
  end

  describe '#as_json' do
    wrap_context 'using fixture', 'with abstract' do
      let(:expected) { { 'abstract' => '' } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with abstract with text' do
      let(:expected) { { 'abstract' => 'Also requires Time.' } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with api' do
      let(:expected) { { 'api' => metadata.api } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with api private' do
      let(:expected) { { 'api' => metadata.api } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with authors' do
      let(:expected) { { 'authors' => metadata.authors } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with deprecated' do
      let(:expected) { { 'deprecated' => metadata.deprecated } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with deprecated with text' do
      let(:expected) { { 'deprecated' => metadata.deprecated } }

      it { expect(metadata.as_json).to be == expected }
    end

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

    wrap_context 'using fixture', 'with since' do
      let(:expected) { { 'since' => metadata.since } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with todos' do
      let(:expected) { { 'todos' => metadata.todos } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with versions' do
      let(:expected) { { 'versions' => metadata.versions } }

      it { expect(metadata.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        {
          'abstract'   => metadata.abstract,
          'api'        => metadata.api,
          'authors'    => metadata.authors,
          'deprecated' => metadata.deprecated,
          'examples'   => metadata.examples,
          'notes'      => metadata.notes,
          'see'        => metadata.see,
          'since'      => metadata.since,
          'todos'      => metadata.todos,
          'versions'   => metadata.versions
        }
      end

      it { expect(metadata.as_json).to be == expected }
    end
  end

  describe '#authors' do
    include_examples 'should define reader', :authors, []

    wrap_context 'using fixture', 'with authors' do
      let(:expected) do
        [
          'Alan Bradley',
          'Ed Dillinger',
          'Kevin Flynn'
        ]
      end

      it { expect(metadata.authors).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          'Alan Bradley',
          'Ed Dillinger',
          'Kevin Flynn'
        ]
      end

      it { expect(metadata.authors).to be == expected }
    end
  end

  describe '#deprecated' do
    include_examples 'should define reader', :deprecated, nil

    wrap_context 'using fixture', 'with deprecated' do
      it { expect(metadata.deprecated).to be == '' }
    end

    wrap_context 'using fixture', 'with deprecated with text' do
      it { expect(metadata.deprecated).to be == 'Alas, poor Yorick!' }
    end

    wrap_context 'using fixture', 'with everything' do
      it { expect(metadata.deprecated).to be == 'Alas, poor Yorick!' }
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

  describe '#since' do
    include_examples 'should define reader', :since, []

    wrap_context 'using fixture', 'with since' do
      let(:expected) { %w[alpha beta] }

      it { expect(metadata.since).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) { %w[alpha beta] }

      it { expect(metadata.since).to be == expected }
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

  describe '#versions' do
    include_examples 'should define reader', :versions, []

    wrap_context 'using fixture', 'with versions' do
      let(:expected) { %w[1.0 1.0.10.101] }

      it { expect(metadata.versions).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) { %w[1.0 1.0.10.101] }

      it { expect(metadata.versions).to be == expected }
    end
  end
end
