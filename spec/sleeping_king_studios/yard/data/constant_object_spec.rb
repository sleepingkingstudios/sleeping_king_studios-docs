# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/constant_object'

require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::ConstantObject do
  include Spec::Support::Fixtures

  subject(:constant_object) do
    described_class.new(native: native, registry: registry)
  end

  include_context 'with fixture files', 'constants'

  let(:fixture)    { 'basic.rb' }
  let(:const_name) { 'GRAVITY' }
  let(:registry)   { ::YARD::Registry }
  let(:native)     { registry.find { |obj| obj.title == const_name } }

  def format_see_tag(tag)
    SleepingKingStudios::Yard::Data::SeeTag
      .new(native: tag, registry: ::YARD::Registry)
      .as_json
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:native, :registry)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'name'              => constant_object.name,
        'slug'              => constant_object.slug,
        'value'             => constant_object.value,
        'short_description' => constant_object.short_description
      }
    end

    it { expect(constant_object).to respond_to(:as_json).with(0).arguments }

    it { expect(constant_object.as_json).to be == expected }

    wrap_context 'using fixture', 'undocumented' do
      it { expect(constant_object.description).to be nil }
    end

    wrap_context 'using fixture', 'with full description' do
      let(:expected) do
        super().merge('description' => constant_object.description)
      end

      it { expect(constant_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with metadata' do
      let(:expected) do
        super().merge('metadata' => constant_object.metadata)
      end

      it { expect(constant_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        super().merge(
          'description' => constant_object.description,
          'metadata'    => constant_object.metadata
        )
      end

      it { expect(constant_object.as_json).to be == expected }
    end
  end

  describe '#description' do
    include_examples 'should define reader', :description, nil

    wrap_context 'using fixture', 'undocumented' do
      it { expect(constant_object.description).to be nil }
    end

    wrap_context 'using fixture', 'with full description' do
      let(:expected) do
        <<~TEXT.strip
          Specifically, the acceleration due to gravity at the surface of an Earth-like
          planet, approximately speaking.
        TEXT
      end

      it { expect(constant_object.description.class).to be String }

      it { expect(constant_object.description).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        <<~TEXT.strip
          Specifically, the acceleration due to gravity at the surface of an Earth-like
          planet, approximately speaking.
        TEXT
      end

      it { expect(constant_object.description).to be == expected }
    end
  end

  describe '#metadata' do
    include_examples 'should define reader', :metadata, {}

    wrap_context 'using fixture', 'with metadata' do
      let(:see_tags) do
        native
          .tags
          .select { |tag| tag.tag_name == 'see' }
          .map { |tag| format_see_tag(tag) }
      end
      let(:expected) do
        {
          'notes'    => ['This is a note.'],
          'examples' => [
            {
              'name' => 'Named Example',
              'text' => '# This is a named example.'
            }
          ],
          'see'      => see_tags,
          'todos'    => ['Remove the plutonium.']
        }
      end

      it { expect(constant_object.metadata).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:see_tags) do
        native
          .tags
          .select { |tag| tag.tag_name == 'see' }
          .map { |tag| format_see_tag(tag) }
      end
      let(:expected) do
        {
          'notes'    => ['This is a note.'],
          'examples' => [
            {
              'name' => 'Named Example',
              'text' => '# This is a named example.'
            }
          ],
          'see'      => see_tags,
          'todos'    => ['Remove the plutonium.']
        }
      end

      it { expect(constant_object.metadata).to be == expected }
    end
  end

  describe '#name' do
    include_examples 'should define reader', :name, 'GRAVITY'

    wrap_context 'using fixture', 'with complex name' do
      let(:const_name) { 'SPEED_OF_LIGHT' }

      it { expect(constant_object.name).to be == const_name }
    end
  end

  describe '#native' do
    include_examples 'should define private reader', :native, -> { native }
  end

  describe '#registry' do
    include_examples 'should define private reader',
      :registry,
      -> { ::YARD::Registry }
  end

  describe '#short_description' do
    let(:expected) { 'A very attractive force.' }

    include_examples 'should define reader', :short_description, -> { expected }

    it { expect(constant_object.short_description.class).to be String }

    wrap_context 'using fixture', 'undocumented' do
      it { expect(constant_object.short_description).to be == '' }
    end

    wrap_context 'using fixture', 'with full description' do
      it { expect(constant_object.short_description).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      it { expect(constant_object.short_description).to be == expected }
    end
  end

  describe '#slug' do
    include_examples 'should define reader', :slug, 'gravity'

    wrap_context 'using fixture', 'with complex name' do
      let(:const_name) { 'SPEED_OF_LIGHT' }

      it { expect(constant_object.slug).to be == 'speed-of-light' }
    end
  end

  describe '#value' do
    let(:expected) { "'9.81 meters per second squared'" }

    include_examples 'should define reader', :value, -> { expected }

    wrap_context 'using fixture', 'with everything' do
      it { expect(constant_object.value).to be == expected }
    end
  end
end
