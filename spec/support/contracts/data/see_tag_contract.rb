# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'support/contracts/data'
require 'support/contracts/data/base_contract'

module Spec::Support::Contracts::Data
  class ShouldBeASeeTagObject
    extend RSpec::SleepingKingStudios::Contract

    # @!method apply(example_group)
    #   Adds the contract to the example group.
    #
    #   @param expected_json [Hash{String => Object}] the expected base response
    #     for #as_json.
    contract do |expected_json: nil|
      include Spec::Support::Contracts::Data

      include_contract 'should be a data object',
        expected_json:    expected_json,
        skip_constructor: true

      describe '.new' do
        it 'should define the constructor' do
          expect(described_class)
            .to be_constructible
            .with(0).arguments
            .and_keywords(:native, :parent)
        end
      end

      describe '#parent' do
        include_examples 'should define reader', :parent, -> { parent }
      end
    end
  end
end
