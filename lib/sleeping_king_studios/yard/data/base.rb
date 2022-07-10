# frozen_string_literal: true

require 'sleeping_king_studios/yard/data'

module SleepingKingStudios::Yard::Data
  # Base object representing a Ruby object documented in YARD.
  #
  # @abstract
  class Base
    # @param native [YARD::Tags::Tag] the YARD object representing the @see tag.
    # @param registry [Enumerable] the YARD registry.
    def initialize(native:, registry:)
      @native   = native
      @registry = registry
    end

    # Generates a JSON-compatible representation of the namespace.
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
      tools.string_tools.underscore(str).tr('_', '-').tr(':', '-')
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
