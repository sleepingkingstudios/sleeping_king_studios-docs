# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/types/parameterized_type'

require 'support/contracts/data/type_contract'

RSpec.describe SleepingKingStudios::Yard::Data::Types::ParameterizedType do
  include Spec::Support::Contracts::Data

  subject(:type) do
    described_class.new(
      items: items,
      name:  name,
      **constructor_options
    )
  end

  shared_context 'when initialized with items' do
    let(:items) do
      [
        SleepingKingStudios::Yard::Data::Types::Type
          .new(name: 'String'),
        SleepingKingStudios::Yard::Data::Types::Type
          .new(name: '#to_s'),
        SleepingKingStudios::Yard::Data::Types::Type
          .new(name: 'nil')
      ]
    end
  end

  shared_context 'when initialized with nested types' do
    let(:items) do
      [
        described_class.new(
          items: [
            SleepingKingStudios::Yard::Data::Types::Type.new(
              name: 'ScienceExperiment'
            )
          ],
          name:  'Payload'
        )
      ]
    end
  end

  let(:name)                { 'Rocket' }
  let(:items)               { [] }
  let(:constructor_options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:items, :name, :ordered)
    end
  end

  include_contract 'should be a type object',
    expected_json: lambda {
      {
        'items' => type.items.map(&:as_json),
        'name'  => type.name
      }
    }

  describe '#as_json' do
    let(:expected) do
      {
        'items' => type.items.map(&:as_json),
        'name'  => type.name
      }
    end

    wrap_context 'when initialized with items' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.as_json).to be == expected }
    end

    wrap_context 'when initialized with nested types' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.as_json).to be == expected }
    end

    context 'when initialized with ordered: false' do
      let(:constructor_options) { super().merge(ordered: false) }

      it { expect(type.as_json).to be == expected }
    end

    context 'when initialized with ordered: true' do
      let(:constructor_options) { super().merge(ordered: true) }
      let(:expected)            { super().merge('ordered' => true) }

      it { expect(type.as_json).to be == expected }
    end
  end

  describe '#inspect' do
    let(:expected) do
      "#<ParameterizedType @name=#{name.inspect} @ordered=#{type.ordered?} " \
        "@items=[#{type.items.map(&:inspect).join(', ')}]>"
    end

    it { expect(type.inspect).to be == expected }

    wrap_context 'when initialized with items' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.inspect).to be == expected }
    end

    wrap_context 'when initialized with nested types' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.inspect).to be == expected }
    end

    context 'when initialized with ordered: false' do
      let(:constructor_options) { super().merge(ordered: false) }

      it { expect(type.inspect).to be == expected }
    end

    context 'when initialized with ordered: true' do
      let(:constructor_options) { super().merge(ordered: true) }

      it { expect(type.inspect).to be == expected }
    end
  end

  describe '#items' do
    include_examples 'should define reader', :items, []

    wrap_context 'when initialized with items' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.items).to be == items }
    end

    wrap_context 'when initialized with nested types' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      it { expect(type.items).to be == items }
    end
  end

  describe '#ordered?' do
    include_examples 'should define predicate', :ordered?, false

    context 'when initialized with ordered: false' do
      let(:constructor_options) { super().merge(ordered: false) }

      it { expect(type.ordered?).to be false }
    end

    context 'when initialized with ordered: true' do
      let(:constructor_options) { super().merge(ordered: true) }

      it { expect(type.ordered?).to be true }
    end
  end
end
