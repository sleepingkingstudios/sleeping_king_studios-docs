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

  # @todo: Remove this.
  before(:context) { YARD::Registry.clear } # rubocop:disable RSpec/BeforeAfterAll

  # @todo: Remove this.
  after(:example) { YARD::Registry.clear }

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
      before(:example) { YARD.parse }

      it { expect(described_class.build.items).to match_array expected }
    end
  end

  describe '.clear' do
    let(:expected) { [YARD::Registry.root, *YARD::Registry.to_a] }

    before(:example) { described_class.instance }

    it { expect(described_class).to respond_to(:clear).with(0).arguments }

    it 'should clear the cache' do
      described_class.clear

      YARD.parse('spec/fixtures')

      expect(described_class.instance).to be == expected
    end
  end

  describe '.instance' do
    let(:expected) { [YARD::Registry.root] }

    before(:example) { described_class.clear }

    include_examples 'should define class reader', :instance, -> { expected }

    it 'should cache the result' do
      expect { YARD.parse('spec/fixtures') }
        .not_to change(described_class, :instance)
    end

    context 'when the yard registry is populated' do
      let(:expected) { [YARD::Registry.root, *YARD::Registry.to_a] }

      before(:example) { YARD.parse }

      include_examples 'should define class reader', :instance, -> { expected }

      it 'should cache the result' do
        expect { YARD.parse('spec/fixtures') }
          .not_to change(described_class, :instance)
      end
    end
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
