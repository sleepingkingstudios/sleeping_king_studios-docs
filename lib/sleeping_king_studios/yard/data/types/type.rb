# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'

require 'sleeping_king_studios/yard/data/types'

module SleepingKingStudios::Yard::Data::Types
  # Base class for a YARD type.
  class Type
    LOWERCASE_LETTER = /\A[[:lower:]]/.freeze
    private_constant :LOWERCASE_LETTER

    # @param name [String] the name of the type.
    def initialize(name:)
      @name     = name
      @registry = SleepingKingStudios::Yard::Registry.instance
    end

    # @return [String] the name of the type.
    attr_reader :name

    # @return [Boolean] true if the other object is an instance of the same Type
    #   class and has the same JSON representation; otherwise false.
    def ==(other)
      return false unless other.instance_of?(self.class)

      other.as_json == as_json
    end

    # Generates a JSON-compatible representation of the type.
    #
    # Returns a Hash with the following keys:
    #
    # - 'name': The name of the type.
    # - (Optional) 'path': The relative path to the referenced class or module,
    #   if the class or module is documented by YARD.
    #
    # @return [Hash] the JSON representation.
    def as_json
      json = { 'name' => name }

      return json unless exists?

      json.merge('path' => path)
    end

    # @return [Boolean] true if the type is a class or module documented by
    #   YARD; otherwise false.
    def exists?
      return @exists unless @exists.nil?

      return @exists = false if literal? || method?

      @exists =
        SleepingKingStudios::Yard::RegistryQuery
        .new(registry: registry)
        .definition_exists?(name)
    end

    # @return [String] a user-friendly representation of the Type.
    def inspect
      "#<#{self.class.name.split('::').last} #{inspect_attributes}>"
    end

    # @return [Boolean] true if the type is a literal value; otherwise false.
    def literal?
      name.match?(LOWERCASE_LETTER)
    end

    # @return [Boolean] true if the name is a method name, otherwise false.
    def method?
      name.start_with?('.') || name.start_with?('#')
    end

    # @return [String, nil] the qualified relative path of the definition, or
    #   nil if the type is not a class or module or it is not documented by
    #   YARD.
    def path
      return nil unless exists?

      @path ||= name.split('::').map { |str| slugify(str) }.join('/')
    end

    private

    attr_reader :registry

    def inspect_attributes
      "@name=#{name.inspect}"
    end

    def slugify(str)
      tools.string_tools.underscore(str).tr('_', '-')
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
