# frozen_string_literal: true

require 'yard'

require 'sleeping_king_studios/yard/data/namespace_object'

RSpec.describe SleepingKingStudios::Yard::Data::NamespaceObject do
  subject(:namespace) { described_class.new(native) }

  shared_context 'using fixture' do |fixture_name| # rubocop:disable RSpec/ContextWording
    let(:fixture) { "#{fixture_name.tr ' ', '_'}.rb" }
  end

  let(:fixture) { 'empty.rb' }
  let(:native)  { ::YARD::Registry.root }

  around(:example) do |example|
    ::YARD.parse(File.join('spec/fixtures/namespaces', fixture))

    example.call
  ensure
    ::YARD::Registry.clear
  end

  describe '.new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#as_json' do
    let(:expected) do
      {
        'class_attributes'    => namespace.class_attributes,
        'class_methods'       => namespace.class_methods,
        'constants'           => namespace.constants,
        'defined_classes'     => namespace.defined_classes,
        'defined_modules'     => namespace.defined_modules,
        'instance_attributes' => namespace.instance_attributes,
        'instance_methods'    => namespace.instance_methods,
        'name'                => namespace.name,
        'slug'                => namespace.slug
      }
    end

    it { expect(namespace).to respond_to(:as_json).with(0).arguments }

    it { expect(namespace.as_json).to be == expected }

    wrap_context 'using fixture', 'with class attributes' do
      it { expect(namespace.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with class methods' do
      it { expect(namespace.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with constants' do
      it { expect(namespace.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with defined classes' do
      it { expect(namespace.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with defined modules' do
      it { expect(namespace.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with instance attributes' do
      it { expect(namespace.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with instance methods' do
      it { expect(namespace.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      it { expect(namespace.as_json).to be == expected }
    end
  end

  describe '#class_attributes' do
    include_examples 'should define reader', :class_attributes, []

    wrap_context 'using fixture', 'with class attributes' do
      let(:expected) do
        [
          {
            'name'  => 'gravity',
            'read'  => true,
            'write' => false
          },
          {
            'name'  => 'sandbox_mode',
            'read'  => true,
            'write' => true
          },
          {
            'name'  => 'secret_key',
            'read'  => false,
            'write' => true
          }
        ]
      end

      it { expect(namespace.class_attributes).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'name'  => 'gravity',
            'read'  => true,
            'write' => false
          },
          {
            'name'  => 'sandbox_mode',
            'read'  => true,
            'write' => true
          },
          {
            'name'  => 'secret_key',
            'read'  => false,
            'write' => true
          }
        ]
      end

      it { expect(namespace.class_attributes).to be == expected }
    end
  end

  describe '#class_methods' do
    include_examples 'should define reader', :class_methods, []

    wrap_context 'using fixture', 'with class methods' do
      let(:expected) { %w[calculate_isp plot_trajectory] }

      it { expect(namespace.class_methods).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) { %w[calculate_isp plot_trajectory] }

      it { expect(namespace.class_methods).to be == expected }
    end
  end

  describe '#constants' do
    include_examples 'should define reader', :constants, []

    wrap_context 'using fixture', 'with constants' do
      let(:expected) { %w[ELDRITCH SQUAMOUS] }

      it { expect(namespace.constants).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) { %w[ELDRITCH SQUAMOUS] }

      it { expect(namespace.constants).to be == expected }
    end
  end

  describe '#defined_classes' do
    include_examples 'should define reader', :defined_classes, []

    wrap_context 'using fixture', 'with defined classes' do
      let(:expected) { %w[Assembly Part Rocket] }

      it { expect(namespace.defined_classes).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) { %w[Assembly Part Rocket] }

      it { expect(namespace.defined_classes).to be == expected }
    end
  end

  describe '#defined_modules' do
    include_examples 'should define reader', :defined_modules, []

    wrap_context 'using fixture', 'with defined modules' do
      let(:expected) { %w[Alchemy Clockwork Sorcery] }

      it { expect(namespace.defined_modules).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) { %w[Alchemy Clockwork Sorcery] }

      it { expect(namespace.defined_modules).to be == expected }
    end
  end

  describe '#instance_attributes' do
    include_examples 'should define reader', :instance_attributes, []

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'name'  => 'base_mana',
            'read'  => true,
            'write' => false
          },
          {
            'name'  => 'magic_enabled',
            'read'  => true,
            'write' => true
          },
          {
            'name'  => 'secret_formula',
            'read'  => false,
            'write' => true
          }
        ]
      end

      it { expect(namespace.instance_attributes).to be == expected }
    end

    wrap_context 'using fixture', 'with instance attributes' do
      let(:expected) do
        [
          {
            'name'  => 'base_mana',
            'read'  => true,
            'write' => false
          },
          {
            'name'  => 'magic_enabled',
            'read'  => true,
            'write' => true
          },
          {
            'name'  => 'secret_formula',
            'read'  => false,
            'write' => true
          }
        ]
      end

      it { expect(namespace.instance_attributes).to be == expected }
    end
  end

  describe '#instance_methods' do
    include_examples 'should define reader', :instance_methods, []

    wrap_context 'using fixture', 'with instance methods' do
      let(:expected) { %w[convert_mana summon_dark_lord] }

      it { expect(namespace.instance_methods).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) { %w[convert_mana summon_dark_lord] }

      it { expect(namespace.instance_methods).to be == expected }
    end
  end

  describe '#name' do
    include_examples 'should define reader', :name, ''
  end

  describe '#native' do
    include_examples 'should define private reader', :native, -> { native }
  end

  describe '#slug' do
    include_examples 'should define reader', :slug, ''
  end
end
