# frozen_string_literal: true

require 'sleeping_king_studios/docs/yard/registry'

RSpec.describe SleepingKingStudios::Docs::Yard::Registry do
  subject(:registry) { described_class.new(**options) }

  shared_context 'when initialized with items' do
    let(:items) do
      Array.new(3) { instance_double(YARD::CodeObjects::Base) }
    end
    let(:options) { super().merge(items:) }
  end

  let(:options) { {} }

  it { expect(described_class).to be < Enumerable }

  describe '::EMPTY' do
    subject(:registry) { described_class::EMPTY }

    it { expect(registry).to be_a described_class }

    describe '#items' do
      it { expect(registry.items).to be == [] }
    end
  end

  describe '.build' do
    let(:expected) { [YARD::Registry.root, *YARD::Registry.to_a] }

    it { expect(described_class).to respond_to(:build).with(0).arguments }

    it { expect(described_class.build).to be_a described_class }

    it { expect(described_class.build.items).to match_array expected }

    context 'when the yard registry is populated' do
      around(:example) do |example|
        YARD::Registry.clear

        YARD.parse

        example.call
      ensure
        YARD::Registry.clear
      end

      it { expect(described_class.build.items).to match_array expected }
    end
  end

  describe '.provider' do
    let(:provider) { described_class.provider }

    include_examples 'should define class reader', :provider

    it { expect(provider).to be_a Plumbum::OneProvider }

    it { expect(provider.key).to eq 'registry' }

    it { expect(provider.value).to be nil }
  end

  describe '#each' do
    it { expect(registry).to respond_to(:each).with(0).arguments.and_a_block }

    it { expect(registry.each).to be_a Enumerator }

    it { expect(registry.each.to_a).to eq [] }

    describe 'with a block' do
      it { expect { |block| registry.each(&block) }.not_to yield_control }
    end

    wrap_context 'when initialized with items' do
      it { expect(registry.each.to_a).to eq items }

      describe 'with a block' do
        it 'should enumerate the items' do
          expect { |block| registry.each(&block) }
            .to yield_successive_args(*items)
        end
      end
    end
  end

  describe '#items' do
    include_examples 'should define reader', :items, []

    it { expect(registry).to have_aliased_method(:items).as(:to_a) }

    wrap_context 'when initialized with items' do
      it { expect(registry.items).to eq items }
    end
  end
end
