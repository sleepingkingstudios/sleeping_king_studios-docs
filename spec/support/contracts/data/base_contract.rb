# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'support/contracts/data'

module Spec::Support::Contracts::Data
  class ShouldBeADataObject
    extend RSpec::SleepingKingStudios::Contract

    # @!method apply(example_group)
    #   Adds the contract to the example group.
    #
    #   @param constructor [Boolean] if true, assert the standard constructor
    #     for namespace objects.
    #   @param expected_json [Hash{String, Object}] the expected base response
    #     for #as_json.
    contract do |expected_json: nil, constructor: true|
      let(:data_object) { subject }

      before(:context) do
        ::YARD::Registry.clear

        SleepingKingStudios::Yard::Registry.clear
      end

      after(:example) do
        ::YARD::Registry.clear

        SleepingKingStudios::Yard::Registry.clear
      end

      if constructor
        describe '.new' do
          it 'should define the constructor' do
            expect(described_class)
              .to be_constructible
              .with(0).arguments
              .and_keywords(:native)
          end
        end
      end

      describe '#as_json' do
        let(:expected) do
          next instance_exec(&expected_json) if expected_json

          {}
        end

        it { expect(data_object).to respond_to(:as_json).with(0).arguments }

        it { expect(data_object.as_json).to be == expected }
      end

      describe '#native' do
        include_examples 'should define private reader', :native, -> { native }
      end

      describe '#registry' do
        include_examples 'should define private reader',
          :registry,
          -> { be == [::YARD::Registry.root, *::YARD::Registry.to_a] }

        context 'with a mocked registry' do
          let(:mock_registry) do
            [::YARD::Registry.root]
          end

          before(:example) do
            allow(SleepingKingStudios::Yard::Registry)
              .to receive(:instance)
              .and_return(mock_registry)
          end

          it { expect(subject.send(:registry)).to be == mock_registry }
        end
      end
    end
  end
end
