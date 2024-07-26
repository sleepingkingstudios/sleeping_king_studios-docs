# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/types'

module SleepingKingStudios::Yard::Data::Types
  # Represents a YARD type with lists of key types and value types.
  class KeyValueType < SleepingKingStudios::Yard::Data::Types::Type
    # @param keys [Array<SleepingKingStudios::Yard::Data::Types::Type>] the key
    #   types.
    # @param name [String] the name of the type.
    # @param values [Array<SleepingKingStudios::Yard::Data::Types::Type>] the
    #   value types.
    def initialize(keys:, name:, values:)
      super(name:)

      @keys   = keys
      @values = values
    end

    # Generates a JSON-compatible representation of the parameterized type.
    #
    # Returns a Hash with the following keys:
    #
    # - 'name': The name of the type.
    # - 'keys': A JSON representation of the parameterized keys.
    # - 'values': A JSON representation of the parameterized values.
    # - (Optional) 'path': The relative path to the referenced class or module,
    #   if the class or module is documented by YARD.
    #
    # @return [Hash] the JSON representation.
    def as_json
      super.merge(
        'keys'   => keys.map(&:as_json),
        'values' => values.map(&:as_json)
      )
    end

    # @return [Array<SleepingKingStudios::Yard::Data::Types::Type>] the key
    #   types.
    attr_reader :keys

    # @return [Array<SleepingKingStudios::Yard::Data::Types::Type>] the value
    #   types.
    attr_reader :values

    private

    def inspect_attributes
      "#{super} " \
        "@keys=[#{keys.map(&:inspect).join(', ')}] " \
        "@values=[#{values.map(&:inspect).join(', ')}]"
    end
  end
end
