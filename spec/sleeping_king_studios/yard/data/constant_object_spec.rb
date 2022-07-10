# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/constant_object'

require 'support/contracts/data/base_contract'
require 'support/contracts/data/describable_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::ConstantObject do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:constant_object) do
    described_class.new(native: native, registry: registry)
  end

  include_context 'with fixture files', 'constants'

  let(:fixture)      { 'basic.rb' }
  let(:fixture_name) { 'GRAVITY' }
  let(:registry)     { ::YARD::Registry }
  let(:native)       { registry.find { |obj| obj.title == fixture_name } }

  def self.expected_json
    lambda do
      {
        'name'              => constant_object.name,
        'slug'              => constant_object.slug,
        'value'             => constant_object.value,
        'short_description' => constant_object.short_description
      }
    end
  end

  include_contract 'should be a data object',
    expected_json: expected_json

  include_contract 'should be a describable object',
    basic_name:    'GRAVITY',
    complex_name:  'SPEED_OF_LIGHT',
    scoped_name:   'Cosmos::PhysicalConstants::SPEED_OF_LIGHT',
    description:   'A very attractive force.',
    expected_json: expected_json

  describe '#as_json' do
    let(:expected) { instance_exec(&self.class.expected_json) }

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

  describe '#value' do
    let(:expected) { "'9.81 meters per second squared'" }

    include_examples 'should define reader', :value, -> { expected }

    wrap_context 'using fixture', 'with everything' do
      it { expect(constant_object.value).to be == expected }
    end
  end
end
