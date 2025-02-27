# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'

require 'sleeping_king_studios/docs/data'

module SleepingKingStudios::Docs::Data
  # Base object representing a Ruby object documented in YARD.
  #
  # @abstract
  class Base
    # @param native [YARD::Tags::Tag] the YARD object representing the
    #   documented object.
    def initialize(native:)
      @native   = native
      @registry = SleepingKingStudios::Docs::Registry.instance
    end

    # Generates a JSON-compatible representation of the object.
    #
    # @return [Hash] the JSON representation.
    def as_json
      {}
    end

    private

    attr_reader :native

    attr_reader :registry

    def empty?(value)
      return true if value.nil?

      return false unless value.respond_to?(:empty?)

      value.empty?
    end

    def slugify(str)
      tools.string_tools.underscore(str).tr('_', '-')
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
