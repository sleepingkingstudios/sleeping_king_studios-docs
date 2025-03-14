# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/types'

module SleepingKingStudios::Docs::Data::Types
  # Represents a YARD type with a list of child types.
  class ParameterizedType < SleepingKingStudios::Docs::Data::Types::Type
    # @param items [Array<SleepingKingStudios::Docs::Data::Types::Type>] the
    #   child types.
    # @param name [String] the name of the type.
    # @param ordered [Boolean] if true, indicates the type represents an order-
    #   dependent list.
    def initialize(items:, name:, ordered: false)
      super(name:)

      @items   = items
      @ordered = ordered
    end

    # @return [Array<SleepingKingStudios::Docs::Data::Types::Type>] the child
    #   types.
    attr_reader :items

    # Generates a JSON-compatible representation of the parameterized type.
    #
    # Returns a Hash with the following keys:
    #
    # - 'name': The name of the type.
    # - 'items': A JSON representation of the parameterized items.
    # - (Optional) 'ordered': If true, indicates the type represents an order-
    #   dependent list.
    # - (Optional) 'path': The relative path to the referenced class or module,
    #   if the class or module is documented by YARD.
    #
    # @return [Hash] the JSON representation.
    def as_json
      json = super.merge('items' => items.map(&:as_json))

      return json unless ordered?

      json.merge('ordered' => true)
    end

    # @return [Boolean] if true, indicates the type represents an order-
    #   dependent list.
    def ordered?
      @ordered
    end

    private

    def inspect_attributes
      "#{super} @ordered=#{ordered?} " \
        "@items=[#{items.map(&:inspect).join(', ')}]"
    end
  end
end
