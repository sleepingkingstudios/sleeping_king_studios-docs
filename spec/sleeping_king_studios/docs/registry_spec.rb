# frozen_string_literal: true

require 'sleeping_king_studios/docs/registry'

RSpec.describe SleepingKingStudios::Docs::Registry do
  before(:context) { YARD::Registry.clear } # rubocop:disable RSpec/BeforeAfterAll

  after(:example) { YARD::Registry.clear }

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
end
