# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'support/contracts/data'

module Spec::Support::Contracts::Data
  class ShouldBeATypeObject # rubocop:disable Metrics/ClassLength
    extend RSpec::SleepingKingStudios::Contract

    # @!method apply(example_group)
    #   Adds the contract to the example group.
    #
    #   @param expected_json [Hash{String, Object}] the expected base response
    #     for #as_json.
    contract do |expected_json: nil|
      shared_context 'when the definition exists' do
        let(:query) do
          instance_double(
            SleepingKingStudios::Yard::RegistryQuery,
            definition_exists?: true
          )
        end

        before(:example) do
          allow(SleepingKingStudios::Yard::RegistryQuery)
            .to receive(:new)
            .and_return(query)
        end
      end

      before(:context) { ::YARD::Registry.clear }

      after(:example) { ::YARD::Registry.clear }

      describe '#==' do
        def type_double(mock_class, json)
          mock = instance_double(
            SleepingKingStudios::Yard::Data::Types::Type,
            as_json: json
          )

          allow(mock).to receive(:instance_of?) do |expected_class|
            expected_class == mock_class
          end

          mock
        end

        describe 'with nil' do
          it { expect(type == nil).to be false } # rubocop:disable Style/NilComparison
        end

        describe 'with an object' do
          it { expect(type == Object.new.freeze).to be false }
        end

        describe 'with a type with non-matching class' do
          let(:other) do
            type_double(Spec::CustomType, type.as_json)
          end

          example_class 'Spec::CustomType',
            SleepingKingStudios::Yard::Data::Types::Type

          it { expect(type == other).to be false }
        end

        describe 'with a type with non-matching json' do
          let(:other) do
            type_double(type.class, { 'name' => 'Space' })
          end

          it { expect(type == other).to be false }
        end

        describe 'with a type with matching class and json' do
          let(:other) do
            type_double(type.class, type.as_json)
          end

          it { expect(type == other).to be true }
        end
      end

      describe '#as_json' do
        let(:expected) do
          next instance_exec(&expected_json) if expected_json

          { 'name' => type.name }
        end

        it { expect(type).to respond_to(:as_json).with(0).arguments }

        it { expect(type.as_json).to be == expected }

        wrap_context 'when the definition exists' do
          let(:expected) do
            super().merge('path' => type.path)
          end

          it { expect(type.as_json).to be == expected }
        end

        context 'when initialized with a class method name' do
          let(:name) { '.build' }

          it { expect(type.as_json).to be == expected }
        end

        context 'when initialized with an instance method name' do
          let(:name) { '#call' }

          it { expect(type.as_json).to be == expected }
        end

        context 'when initialized with a literal' do
          let(:name) { 'nil' }

          it { expect(type.as_json).to be == expected }
        end

        context 'when initialized with a scoped name' do
          let(:name) { 'Cosmos::LocalDimension::SpaceAndTime' }

          it { expect(type.as_json).to be == expected }

          wrap_context 'when the definition exists' do
            let(:expected) do
              super().merge('path' => type.path)
            end

            it { expect(type.as_json).to be == expected }
          end
        end
      end

      describe '#exists?' do
        let(:query) do
          instance_double(
            SleepingKingStudios::Yard::RegistryQuery,
            definition_exists?: false
          )
        end

        before(:example) do
          allow(SleepingKingStudios::Yard::RegistryQuery)
            .to receive(:new)
            .and_return(query)
        end

        include_examples 'should define predicate', :exists?, false

        it 'should query the registry' do
          type.exists?

          expect(query)
            .to have_received(:definition_exists?)
            .with(type.name)
        end

        context 'when the definition exists' do
          before(:example) do
            allow(query).to receive(:definition_exists?).and_return(true)
          end

          it { expect(type.exists?).to be true }
        end

        context 'when initialized with a class method name' do
          let(:name) { '.build' }

          it { expect(type.exists?).to be false }

          it 'should not query the registry' do
            type.exists?

            expect(query)
              .not_to have_received(:definition_exists?)
              .with(type.name)
          end
        end

        context 'when initialized with an instance method name' do
          let(:name) { '#call' }

          it { expect(type.exists?).to be false }

          it 'should not query the registry' do
            type.exists?

            expect(query)
              .not_to have_received(:definition_exists?)
              .with(type.name)
          end
        end

        context 'when initialized with a literal' do
          let(:name) { 'nil' }

          it { expect(type.exists?).to be false }

          it 'should not query the registry' do
            type.exists?

            expect(query)
              .not_to have_received(:definition_exists?)
              .with(type.name)
          end
        end
      end

      describe '#literal?' do
        include_examples 'should define predicate', :literal?, false

        context 'when initialized with a class method name' do
          let(:name) { '.build' }

          it { expect(type.literal?).to be false }
        end

        context 'when initialized with an instance method name' do
          let(:name) { '#call' }

          it { expect(type.literal?).to be false }
        end

        context 'when initialized with a literal' do
          let(:name) { 'nil' }

          it { expect(type.literal?).to be true }
        end
      end

      describe '#method?' do
        include_examples 'should define predicate', :method?, false

        context 'when initialized with a class method name' do
          let(:name) { '.build' }

          it { expect(type.method?).to be true }
        end

        context 'when initialized with an instance method name' do
          let(:name) { '#call' }

          it { expect(type.method?).to be true }
        end

        context 'when initialized with a literal' do
          let(:name) { 'nil' }

          it { expect(type.method?).to be false }
        end
      end

      describe '#name' do
        include_examples 'should define reader', :name, -> { name }

        context 'when initialized with a class method name' do
          let(:name) { '.build' }

          it { expect(type.name).to be == name }
        end

        context 'when initialized with an instance method name' do
          let(:name) { '#call' }

          it { expect(type.name).to be == name }
        end

        context 'when initialized with a literal' do
          let(:name) { 'nil' }

          it { expect(type.name).to be == name }
        end

        context 'when initialized with a scoped name' do
          let(:name) { 'Cosmos::LocalDimension::SpaceAndTime' }

          it { expect(type.name).to be == name }
        end
      end

      describe '#path' do
        include_examples 'should define reader', :path, nil

        context 'when initialized with a class method name' do
          let(:name) { '.build' }

          it { expect(type.path).to be nil }
        end

        context 'when initialized with an instance method name' do
          let(:name) { '#call' }

          it { expect(type.path).to be nil }
        end

        context 'when initialized with a literal' do
          let(:name) { 'nil' }

          it { expect(type.path).to be nil }
        end

        wrap_context 'when the definition exists' do
          it { expect(type.path).to be == 'rocket' }
        end

        context 'when initialized with a scoped name' do
          let(:name) { 'Cosmos::LocalDimension::SpaceAndTime' }

          it { expect(type.path).to be nil }

          wrap_context 'when the definition exists' do
            let(:expected) { 'cosmos/local-dimension/space-and-time' }

            it { expect(type.path).to be == expected }
          end
        end
      end

      describe '#registry' do
        include_examples 'should define private reader',
          :registry,
          -> { ::YARD::Registry }
      end
    end
  end
end
