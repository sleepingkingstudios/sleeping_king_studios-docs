# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/class_object'

require 'support/contracts/data/base_contract'
require 'support/contracts/data/describable_contract'
require 'support/contracts/data/namespace_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::ClassObject do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:class_object) { described_class.new(native: native) }

  include_context 'with fixture files', 'classes'

  let(:fixture)      { 'basic.rb' }
  let(:fixture_name) { 'Rocketry' }
  let(:native) do
    ::YARD::Registry.find { |obj| obj.title == fixture_name }
  end

  def self.expected_json # rubocop:disable Metrics/MethodLength
    lambda do
      {
        'name'              => class_object.name,
        'slug'              => class_object.slug,
        'type'              => class_object.type,
        'files'             => class_object.files,
        'constructor'       => class_object.constructor?,
        'short_description' => class_object.short_description,
        'data_path'         => class_object.data_path
      }
    end
  end

  include_contract 'should be a data object',
    expected_json: expected_json

  include_contract 'should be a describable object',
    basic_name:    'Rocketry',
    complex_name:  'AdvancedRocketry',
    scoped_name:   'RocketScience::Engineering::Rocketry',
    description:   'This class is out of this world.',
    expected_json: expected_json

  include_contract 'should implement the namespace methods',
    expected_json:  expected_json,
    include_mixins: true,
    inherit_mixins: true

  describe '#as_json' do
    let(:expected) { instance_exec(&self.class.expected_json) }

    wrap_context 'using fixture', 'with subclasses' do
      let(:expected) do
        super().merge('direct_subclasses' => class_object.direct_subclasses)
      end

      it { expect(class_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with inherited classes' do
      let(:expected) do
        super().merge(
          'class_methods'     => class_object.class_methods,
          'inherited_classes' => class_object.inherited_classes,
          'instance_methods'  => class_object.instance_methods
        )
      end

      it { expect(class_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with inherited constructor' do
      let(:expected) do
        super().merge(
          'instance_methods'  => class_object.instance_methods,
          'inherited_classes' => class_object.inherited_classes
        )
      end

      it { expect(class_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        super().merge(
          'class_attributes'    => class_object.class_attributes,
          'class_methods'       => class_object.class_methods,
          'constants'           => class_object.constants,
          'defined_classes'     => class_object.defined_classes,
          'defined_modules'     => class_object.defined_modules,
          'description'         => class_object.description,
          'direct_subclasses'   => class_object.direct_subclasses,
          'extended_modules'    => class_object.extended_modules,
          'included_modules'    => class_object.included_modules,
          'inherited_classes'   => class_object.inherited_classes,
          'instance_attributes' => class_object.instance_attributes,
          'instance_methods'    => class_object.instance_methods,
          'metadata'            => class_object.metadata
        )
      end

      it { expect(class_object.as_json).to deep_match expected }
    end
  end

  describe '#constructor?' do
    include_examples 'should define predicate', :constructor?, false

    wrap_context 'using fixture', 'with constructor' do
      it { expect(class_object.constructor?).to be true }
    end

    wrap_context 'using fixture', 'with inherited constructor' do
      it { expect(class_object.constructor?).to be true }
    end

    wrap_context 'using fixture', 'with everything' do
      it { expect(class_object.constructor?).to be true }
    end
  end

  describe '#direct_subclasses' do
    include_examples 'should define reader', :direct_subclasses, []

    wrap_context 'using fixture', 'with subclasses' do
      let(:expected) do
        [
          {
            'name' => 'HighTech::SolarSailing',
            'path' => 'high-tech/solar-sailing',
            'slug' => 'solar-sailing'
          },
          {
            'name' => 'LiquidFueledRocketry',
            'path' => 'liquid-fueled-rocketry',
            'slug' => 'liquid-fueled-rocketry'
          },
          {
            'name' => 'NuclearRocketry',
            'path' => 'nuclear-rocketry',
            'slug' => 'nuclear-rocketry'
          }
        ]
      end

      it { expect(class_object.direct_subclasses).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'name' => 'HighTech::SolarSailing',
            'path' => 'high-tech/solar-sailing',
            'slug' => 'solar-sailing'
          },
          {
            'name' => 'LiquidFueledRocketry',
            'path' => 'liquid-fueled-rocketry',
            'slug' => 'liquid-fueled-rocketry'
          },
          {
            'name' => 'NuclearRocketry',
            'path' => 'nuclear-rocketry',
            'slug' => 'nuclear-rocketry'
          }
        ]
      end

      it { expect(class_object.direct_subclasses).to be == expected }
    end
  end

  describe '#extended_modules' do
    include_examples 'should define reader', :extended_modules, []

    wrap_context 'using fixture', 'with extended modules' do
      let(:expected) do
        [
          {
            'name' => 'Forwardable',
            'slug' => 'forwardable'
          },
          {
            'name' => 'Phenomena::WeatherEffects',
            'path' => 'phenomena/weather-effects',
            'slug' => 'weather-effects'
          },
          {
            'name' => 'Revenge',
            'path' => 'revenge',
            'slug' => 'revenge'
          }
        ]
      end

      it { expect(class_object.extended_modules).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'name' => 'Forwardable',
            'slug' => 'forwardable'
          },
          {
            'name' => 'Phenomena::WeatherEffects',
            'path' => 'phenomena/weather-effects',
            'slug' => 'weather-effects'
          },
          {
            'name' => 'Revenge',
            'path' => 'revenge',
            'slug' => 'revenge'
          }
        ]
      end

      it { expect(class_object.extended_modules).to be == expected }
    end
  end

  describe '#files' do
    let(:expected) { [File.join('spec/fixtures/classes', fixture)] }

    include_examples 'should define reader', :files, -> { expected }

    context 'when the module is defined in multiple files' do
      let(:expected) do
        [
          *super(),
          'spec/fixtures/classes/with_constants.rb',
          'spec/fixtures/classes/with_full_description.rb'
        ]
      end

      before(:example) do
        YARD.parse('spec/fixtures/classes/with_constants.rb')
        YARD.parse('spec/fixtures/classes/with_full_description.rb')
      end

      it { expect(class_object.files).to be == expected }
    end
  end

  describe '#included_modules' do
    include_examples 'should define reader', :included_modules, []

    wrap_context 'using fixture', 'with included modules' do
      let(:expected) do
        [
          {
            'name' => 'Comparable',
            'slug' => 'comparable'
          },
          {
            'name' => 'Dimensions',
            'slug' => 'dimensions',
            'path' => 'dimensions'
          },
          {
            'name' => 'Dimensions::HigherDimensions',
            'slug' => 'higher-dimensions',
            'path' => 'dimensions/higher-dimensions'
          }
        ]
      end

      it { expect(class_object.included_modules).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'name' => 'Comparable',
            'slug' => 'comparable'
          },
          {
            'name' => 'Dimensions',
            'slug' => 'dimensions',
            'path' => 'dimensions'
          },
          {
            'name' => 'Dimensions::HigherDimensions',
            'slug' => 'higher-dimensions',
            'path' => 'dimensions/higher-dimensions'
          }
        ]
      end

      it { expect(class_object.included_modules).to be == expected }
    end
  end

  describe '#inherited_classes' do
    include_examples 'should define reader', :inherited_classes, []

    wrap_context 'using fixture', 'with inherited classes' do
      let(:expected) do
        [
          {
            'name' => 'Physics::RocketScience',
            'slug' => 'rocket-science',
            'path' => 'physics/rocket-science'
          },
          {
            'name' => 'Engineering',
            'slug' => 'engineering',
            'path' => 'engineering'
          }
        ]
      end

      it { expect(class_object.inherited_classes).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'name' => 'Physics::RocketScience',
            'slug' => 'rocket-science',
            'path' => 'physics/rocket-science'
          },
          {
            'name' => 'Engineering',
            'slug' => 'engineering',
            'path' => 'engineering'
          }
        ]
      end

      it { expect(class_object.inherited_classes).to be == expected }
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, 'class'
  end
end
