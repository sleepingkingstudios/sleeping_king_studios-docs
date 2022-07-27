# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/types/key_value_type'

require 'support/contracts/data/type_contract'

RSpec.describe SleepingKingStudios::Yard::Data::Types::KeyValueType do
  include Spec::Support::Contracts::Data

  subject(:type) do
    described_class.new(
      keys:     keys,
      name:     name,
      registry: registry,
      values:   values
    )
  end

  shared_context 'when initialized with keys' do
    let(:keys) do
      [
        SleepingKingStudios::Yard::Data::Types::Type
          .new(name: 'String', registry: registry),
        SleepingKingStudios::Yard::Data::Types::Type
          .new(name: 'Symbol', registry: registry)
      ]
    end
  end

  shared_context 'when initialized with values' do
    let(:values) do
      [
        SleepingKingStudios::Yard::Data::Types::Type
          .new(name: 'Part', registry: registry),
        SleepingKingStudios::Yard::Data::Types::Type
          .new(name: 'Payload', registry: registry)
      ]
    end
  end

  shared_context 'when initialized with keys and values' do
    include_context 'when initialized with keys'
    include_context 'when initialized with values'
  end

  let(:name)   { 'Rocket' }
  let(:keys)   { [] }
  let(:values) { [] }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:keys, :name, :registry, :values)
    end
  end

  include_contract 'should be a type object',
    expected_json: lambda {
      {
        'keys'   => type.keys.map(&:as_json),
        'name'   => type.name,
        'values' => type.values.map(&:as_json)
      }
    }

  describe '#as_json' do
    let(:expected) do
      {
        'keys'   => type.keys.map(&:as_json),
        'name'   => type.name,
        'values' => type.values.map(&:as_json)
      }
    end

    wrap_context 'when initialized with keys' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.as_json).to be == expected }
    end

    wrap_context 'when initialized with values' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.as_json).to be == expected }
    end

    wrap_context 'when initialized with keys and values' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.as_json).to be == expected }
    end
  end

  describe '#inspect' do
    let(:expected) do
      "#<KeyValueType @name=#{name.inspect} " \
        "@keys=[#{type.keys.map(&:inspect).join(', ')}] " \
        "@values=[#{type.values.map(&:inspect).join(', ')}]>"
    end

    it { expect(type.inspect).to be == expected }

    wrap_context 'when initialized with keys' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.inspect).to be == expected }
    end

    wrap_context 'when initialized with values' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.inspect).to be == expected }
    end

    wrap_context 'when initialized with keys and values' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.inspect).to be == expected }
    end
  end

  describe '#keys' do
    include_examples 'should define reader', :keys, []

    wrap_context 'when initialized with keys' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.keys).to be == keys }
    end

    wrap_context 'when initialized with keys and values' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.keys).to be == keys }
    end
  end

  describe '#values' do
    include_examples 'should define reader', :values, []

    wrap_context 'when initialized with values' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.values).to be == values }
    end

    wrap_context 'when initialized with keys and values' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.values).to be == values }
    end
  end
end
