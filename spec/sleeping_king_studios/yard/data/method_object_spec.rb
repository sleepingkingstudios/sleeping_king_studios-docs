# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/method_object'

require 'support/contracts/data/base_contract'
require 'support/contracts/data/describable_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::MethodObject do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:method_object) do
    described_class.new(native: native, registry: registry)
  end

  include_context 'with fixture files', 'methods'

  let(:fixture)      { 'basic.rb' }
  let(:fixture_name) { '#launch' }
  let(:registry)     { ::YARD::Registry }
  let(:native)       { registry.find { |obj| obj.title == fixture_name } }

  def self.expected_json
    lambda do
      {
        'name'      => method_object.name,
        'slug'      => method_object.slug,
        'signature' => method_object.signature
      }
    end
  end

  def parse_type(type)
    SleepingKingStudios::Yard::Data::Types::Parser
      .new(registry: registry)
      .parse(type)
      .map(&:as_json)
  end

  include_contract 'should be a data object',
    expected_json: expected_json

  include_contract 'should be a describable object',
    basic_name:    '#launch',
    complex_name:  '#retrograde_launch',
    scoped_name:   'Wonders::FutureEra#use_space_elevator',
    description:   'You are going to space today.',
    expected_json: expected_json

  describe '#as_json' do
    let(:expected) { instance_exec(&self.class.expected_json) }

    wrap_context 'using fixture', 'with options' do
      let(:expected) do
        super().merge(
          'options' => method_object.options,
          'params'  => method_object.params
        )
      end

      it { expect(method_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with params' do
      let(:expected) { super().merge('params' => method_object.params) }

      it { expect(method_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with raised exceptions' do
      let(:expected) { super().merge('raises' => method_object.raises) }

      it { expect(method_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with return type' do
      let(:expected) { super().merge('returns' => method_object.returns) }

      it { expect(method_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with multiple return types' do
      let(:expected) { super().merge('returns' => method_object.returns) }

      it { expect(method_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with yield' do
      let(:expected) do
        super().merge('yields' => method_object.yields)
      end

      it { expect(method_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with multiple yields' do
      let(:expected) do
        super().merge('yields' => method_object.yields)
      end

      it { expect(method_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with yield params' do
      let(:expected) do
        super().merge('yield_params' => method_object.yield_params)
      end

      it { expect(method_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with yield returns' do
      let(:expected) do
        super().merge('yield_returns' => method_object.yield_returns)
      end

      it { expect(method_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        super().merge(
          'description'   => method_object.description,
          'metadata'      => method_object.metadata,
          'options'       => method_object.options,
          'params'        => method_object.params,
          'raises'        => method_object.raises,
          'returns'       => method_object.returns,
          'yield_params'  => method_object.yield_params,
          'yield_returns' => method_object.yield_returns,
          'yields'        => method_object.yields
        )
      end

      it { expect(method_object.as_json).to be == expected }
    end
  end

  describe '#options' do
    include_examples 'should define reader', :options, []

    wrap_context 'using fixture', 'with options' do
      let(:expected) do
        [
          {
            'name'        => 'options',
            'tag_name'    => 'recovery_transponder',
            'type'        => parse_type('Boolean'),
            'description' => "if true, adds a recovery\ntransponder to the " \
                             'rocket.'
          },
          {
            'name'        => 'options',
            'tag_name'    => 'flight_termination_system',
            'type'        => parse_type('Boolean'),
            'description' => "if true, adds a flight\ntermination system to " \
                             'the rocket in case of launch failure.'
          }
        ]
      end

      it { expect(method_object.options).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'name'        => 'options',
            'tag_name'    => 'recovery_transponder',
            'type'        => parse_type('Boolean'),
            'description' => "if true, adds a recovery\ntransponder to the " \
                             'rocket.'
          },
          {
            'name'        => 'options',
            'tag_name'    => 'flight_termination_system',
            'type'        => parse_type('Boolean'),
            'description' => "if true, adds a flight\ntermination system to " \
                             'the rocket in case of launch failure.'
          }
        ]
      end

      it { expect(method_object.options).to be == expected }
    end
  end

  describe '#params' do
    include_examples 'should define reader', :params, []

    wrap_context 'using fixture', 'with params' do
      let(:expected) do
        [
          {
            'name'        => 'apoapsis',
            'type'        => parse_type('Float'),
            'description' => 'the highest point in the orbit.'
          },
          {
            'name'        => 'payload',
            'type'        => parse_type('Object'),
            'default'     => 'nil',
            'description' => 'the payload to launch.'
          },
          {
            'name'        => 'recovery',
            'type'        => parse_type('Boolean'),
            'default'     => 'false',
            'description' => 'if true, will attempt to recover the rocket ' \
                             "after a\nsuccessful launch."
          },
          {
            'name'        => 'rocket',
            'type'        => parse_type('Rocket'),
            'description' => 'the rocket to launch.'
          }
        ]
      end

      it { expect(method_object.params).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'name'        => 'apoapsis',
            'type'        => parse_type('Float'),
            'description' => 'the highest point in the orbit.'
          },
          {
            'name'        => 'payload',
            'type'        => parse_type('Object'),
            'default'     => 'nil',
            'description' => 'the payload to launch.'
          },
          {
            'name'        => 'recovery',
            'type'        => parse_type('Boolean'),
            'default'     => 'false',
            'description' => 'if true, will attempt to recover the rocket ' \
                             "after a\nsuccessful launch."
          },
          {
            'name'        => 'rocket',
            'type'        => parse_type('Rocket'),
            'description' => 'the rocket to launch.'
          },
          {
            'name'        => 'options',
            'type'        => parse_type('Hash'),
            'description' => 'additional options for the launch.'
          }
        ]
      end

      it { expect(method_object.params).to be == expected }
    end
  end

  describe '#raises' do
    include_examples 'should define reader', :raises, []

    wrap_context 'using fixture', 'with raised exceptions' do
      let(:expected) do
        [
          {
            'type'        => parse_type('AuthorizationError'),
            'description' => 'if the launch has not been authorized.'
          },
          {
            'type'        => parse_type('NotGoingToSpaceTodayError'),
            'description' => 'if the rocket is pointed the wrong way.'
          }
        ]
      end

      it { expect(method_object.raises).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'type'        => parse_type('AuthorizationError'),
            'description' => 'if the launch has not been authorized.'
          },
          {
            'type'        => parse_type('NotGoingToSpaceTodayError'),
            'description' => 'if the rocket is pointed the wrong way.'
          }
        ]
      end

      it { expect(method_object.raises).to be == expected }
    end
  end

  describe '#returns' do
    include_examples 'should define reader', :returns, []

    wrap_context 'using fixture', 'with return type' do
      let(:expected) do
        [
          {
            'type'        => parse_type('Array<String>'),
            'description' => 'an array of strings.'
          }
        ]
      end

      it { expect(method_object.returns).to be == expected }
    end

    wrap_context 'using fixture', 'with multiple return types' do
      let(:expected) do
        [
          {
            'type'        => parse_type('true'),
            'description' => 'if the predicate is true.'
          },
          {
            'type'        => parse_type('false'),
            'description' => 'if the predicate is false.'
          }
        ]
      end

      it { expect(method_object.returns).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'type'        => parse_type('true'),
            'description' => 'if the predicate is true.'
          },
          {
            'type'        => parse_type('false'),
            'description' => 'if the predicate is false.'
          }
        ]
      end

      it { expect(method_object.returns).to be == expected }
    end
  end

  describe '#signature' do
    let(:expected) { 'def launch' }

    include_examples 'should define reader', :signature, -> { expected }

    wrap_context 'using fixture', 'with block parameter' do
      let(:expected) { 'def launch(&block)' }

      it { expect(method_object.signature).to be == expected }
    end

    wrap_context 'using fixture', 'with complex name' do
      let(:fixture_name) { '#retrograde_launch' }
      let(:expected)     { 'def retrograde_launch' }

      it { expect(method_object.signature).to be == expected }
    end

    wrap_context 'using fixture', 'with optional arguments' do
      let(:expected) { 'def launch(payload = nil, mission_flag = nil)' }

      it { expect(method_object.signature).to be == expected }
    end

    wrap_context 'using fixture', 'with optional keywords' do
      let(:expected) { 'def launch(inclination: 0.0, recovery: true)' }

      it { expect(method_object.signature).to be == expected }
    end

    wrap_context 'using fixture', 'with options' do
      let(:expected) { 'def launch(**options)' }

      it { expect(method_object.signature).to be == expected }
    end

    wrap_context 'using fixture', 'with required arguments' do
      let(:expected) { 'def launch(rocket, launchsite)' }

      it { expect(method_object.signature).to be == expected }
    end

    wrap_context 'using fixture', 'with required keywords' do
      let(:expected) { 'def launch(apoapsis:, periapsis:)' }

      it { expect(method_object.signature).to be == expected }
    end

    wrap_context 'using fixture', 'with scoped name' do
      let(:fixture_name) { 'Wonders::FutureEra#use_space_elevator' }
      let(:expected)     { 'def use_space_elevator' }

      it { expect(method_object.signature).to be == expected }
    end

    wrap_context 'using fixture', 'with undocumented parameters' do
      let(:expected) do
        'def launch(rocket, payload = nil, apoapsis:, inclination: 0, &block)'
      end

      it { expect(method_object.signature).to be == expected }
    end

    wrap_context 'using fixture', 'with variadic arguments' do
      let(:expected) { 'def launch(*rideshares)' }

      it { expect(method_object.signature).to be == expected }
    end

    wrap_context 'using fixture', 'with variadic keywords' do
      let(:expected) { 'def launch(**destinations)' }

      it { expect(method_object.signature).to be == expected }
    end

    wrap_context 'using fixture', 'with yield' do
      let(:expected) { 'def launch' }

      it { expect(method_object.signature).to be == expected }
    end

    wrap_context 'using fixture', 'with yield signature' do
      let(:expected) { 'def launch' }

      it { expect(method_object.signature).to be == expected }
    end
  end

  describe '#yield_params' do
    include_examples 'should define reader', :yield_params, []

    wrap_context 'using fixture', 'with yield params' do
      let(:expected) do
        [
          {
            'description' => 'the rocket to launch.',
            'name'        => 'rocket',
            'type'        => parse_type('Rocket')
          },
          {
            'description' => 'the payload to launch.',
            'name'        => 'payload',
            'type'        => parse_type('Object')
          },
          {
            'description' => 'the destinations to visit.',
            'name'        => 'destinations',
            'type'        => parse_type('Hash')
          }
        ]
      end

      it { expect(method_object.yield_params).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'description' => 'the rocket to launch.',
            'name'        => 'rocket',
            'type'        => parse_type('Rocket')
          },
          {
            'default'     => 'nil',
            'description' => 'the payload to launch.',
            'name'        => 'payload',
            'type'        => parse_type('Object')
          },
          {
            'description' => 'the destinations to visit.',
            'name'        => 'destinations',
            'type'        => parse_type('Hash')
          }
        ]
      end

      it { expect(method_object.yield_params).to be == expected }
    end
  end

  describe '#yield_returns' do
    include_examples 'should define reader', :yield_returns, []

    wrap_context 'using fixture', 'with yield returns' do
      let(:expected) do
        [
          {
            'type'        => parse_type('Array<Astronaut, SurfaceSample>'),
            'description' => 'if the mission was crewed.'
          },
          {
            'type'        => parse_type('Array<Signal>'),
            'description' => 'if the mission was automated.'
          }
        ]
      end

      it { expect(method_object.yield_returns).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'type'        => parse_type('Array<Astronaut, SurfaceSample>'),
            'description' => 'if the mission was crewed.'
          },
          {
            'type'        => parse_type('Array<Signal>'),
            'description' => 'if the mission was automated.'
          }
        ]
      end

      it { expect(method_object.yield_returns).to be == expected }
    end
  end

  describe '#yields' do
    include_examples 'should define reader', :yields, []

    wrap_context 'using fixture', 'with yield' do
      let(:expected) do
        [
          {
            'description' => 'executes the mission profile.'
          }
        ]
      end

      it { expect(method_object.yields).to be == expected }
    end

    wrap_context 'using fixture', 'with yield signature' do
      let(:expected) do
        [
          {
            'description' => 'executes the mission profile.',
            'parameters'  => [
              'rocket',
              'payload: nil',
              '**destinations'
            ]
          }
        ]
      end

      it { expect(method_object.yields).to be == expected }
    end

    wrap_context 'using fixture', 'with multiple yields' do
      let(:expected) do
        [
          {
            'description' => 'executes the mission profile.'
          },
          {
            'description' => 'slips the surly bonds of earth.'
          }
        ]
      end

      it { expect(method_object.yields).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'description' => 'executes the mission profile.',
            'parameters'  => [
              'rocket',
              'payload: nil',
              '**destinations'
            ]
          }
        ]
      end

      it { expect(method_object.yields).to be == expected }
    end
  end
end
