# frozen_string_literal: true

require 'plumbum'
require 'sleeping_king_studios/tools/toolbelt'

require 'sleeping_king_studios/docs/data'

module SleepingKingStudios::Docs::Data
  # Base object representing a Ruby object documented in YARD.
  #
  # @abstract
  class Base
    include Plumbum::Consumer
    prepend Plumbum::Parameters

    dependency :registry,
      default: SleepingKingStudios::Docs::Yard::Registry::EMPTY

    provider SleepingKingStudios::Docs::Yard::Registry.provider

    # @param native [YARD::Tags::Tag] the YARD object representing the
    #   documented object.
    def initialize(native:)
      @native = native
    end

    # Generates a JSON-compatible representation of the object.
    #
    # @return [Hash] the JSON representation.
    def as_json
      {}
    end

    private

    attr_reader :native

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
