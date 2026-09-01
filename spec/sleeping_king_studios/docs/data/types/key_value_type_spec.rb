# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/types/key_value_type'

require 'support/deferred/data_examples'

RSpec.describe SleepingKingStudios::Docs::Data::Types::KeyValueType do
  include Spec::Support::Deferred::DataExamples

  subject(:type) do
    described_class.new(
      keys:,
      name:,
      values:
    )
  end

  shared_context 'when initialized with keys' do
    let(:keys) do
      [
        SleepingKingStudios::Docs::Data::Types::Type
          .new(name: 'String'),
        SleepingKingStudios::Docs::Data::Types::Type
          .new(name: 'Symbol')
      ]
    end
  end

  shared_context 'when initialized with values' do
    let(:values) do
      [
        SleepingKingStudios::Docs::Data::Types::Type
          .new(name: 'Part'),
        SleepingKingStudios::Docs::Data::Types::Type
          .new(name: 'Payload')
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
  let(:expected_json) do
    {
      'keys'   => type.keys.map(&:as_json),
      'name'   => type.name,
      'values' => type.values.map(&:as_json)
    }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:keys, :name, :values)
    end
  end

  include_deferred 'should be a type object'

  describe '#as_json' do
    let(:expected) { expected_json }

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
