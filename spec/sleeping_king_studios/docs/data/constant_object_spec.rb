# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/constant_object'

require 'support/deferred/data_examples'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Docs::Data::ConstantObject do
  include Spec::Support::Deferred::DataExamples
  include Spec::Support::Fixtures

  subject(:constant_object) { described_class.new(native:) }

  include_context 'with fixture files', 'constants'

  let(:fixture)      { 'basic.rb' }
  let(:fixture_name) { 'GRAVITY' }
  let(:native) do
    YARD::Registry.find { |obj| obj.title == fixture_name }
  end
  let(:expected_json) do
    {
      'name'              => constant_object.name,
      'slug'              => constant_object.slug,
      'value'             => constant_object.value,
      'short_description' => constant_object.short_description,
      'data_path'         => constant_object.data_path,
      'parent_path'       => constant_object.parent_path
    }
  end

  include_deferred 'should be a data object'

  include_deferred 'should be a describable object',
    basic_name:   'GRAVITY',
    complex_name: 'SPEED_OF_LIGHT',
    scoped_name:  'Cosmos::PhysicalConstants::SPEED_OF_LIGHT',
    description:  'A very attractive force.'

  describe '#as_json' do
    let(:expected) { expected_json }

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

  describe '#parent_path' do
    include_examples 'should define reader', :parent_path, ''

    wrap_context 'using fixture', 'with class scoped name' do
      let(:fixture_name) { 'Cosmos::Physics::SPEED_OF_LIGHT' }
      let(:expected)     { 'cosmos/physics' }

      it { expect(constant_object.parent_path).to be == expected }
    end

    wrap_context 'using fixture', 'with scoped name' do
      let(:fixture_name) { 'Cosmos::PhysicalConstants::SPEED_OF_LIGHT' }
      let(:expected)     { 'cosmos/physical-constants' }

      it { expect(constant_object.parent_path).to be == expected }
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
