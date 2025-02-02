# frozen_string_literal: true

require 'sleeping_king_studios/yard'

module SleepingKingStudios::Yard
  # Checks for the presence of requested data in the YARD registry.
  class RegistryQuery
    # @param registry [Enumerable] the YARD registry.
    def initialize(registry:)
      @registry = registry
    end

    # Checks if the given class method is defined in the registry.
    #
    # @param method_name [String] the name of the method and defining namespace,
    #   if any.
    #
    # @return [Boolean] true if the class method exists, otherwise false.
    def class_method_exists?(method_name)
      # Handle top-level class methods.
      if method_name.start_with?('.')
        return top_level_class_method_exists?(method_name)
      end

      # Handle legacy ::class_method format.
      unless method_name.include?('.')
        return legacy_class_method_exists?(method_name)
      end

      registry.any? do |obj|
        obj.type == :method && obj.scope == :class && obj.title == method_name
      end
    end

    # Checks if the given constant is defined in the registry.
    #
    # @param constant_name [String] the name of the constant and defining
    #   namespace, if any.
    #
    # @return [Boolean] true if the constant exists, otherwise false.
    def constant_exists?(constant_name)
      registry.any? do |obj|
        obj.type == :constant && obj.title == constant_name
      end
    end

    # Checks if the given class or module is defined in the registry.
    #
    # @param module_name [String] the name of the class or module and defining
    #   namespace, if any.
    #
    # @return [Boolean] true if the class or module exists, otherwise false.
    def definition_exists?(module_name)
      registry.any? do |obj|
        (obj.type == :module || obj.type == :class) && obj.title == module_name # rubocop:disable Style/MultipleComparison
      end
    end

    # Checks if the given instance method is defined in the registry.
    #
    # @param method_name [String] the name of the method and defining namespace,
    #   if any.
    #
    # @return [Boolean] true if the instance method exists, otherwise false.
    def instance_method_exists?(method_name)
      registry.any? do |obj|
        obj.type == :method &&
          obj.scope == :instance &&
          obj.title == method_name
      end
    end

    private

    attr_reader :registry

    def legacy_class_method_exists?(method_name)
      method_name = method_name.reverse.sub('::', '.').reverse

      registry.any? do |obj|
        obj.type == :method && obj.scope == :class && obj.title == method_name
      end
    end

    def top_level_class_method_exists?(method_name)
      method_name = "::#{method_name[1..]}"

      registry.any? do |obj|
        obj.type == :method && obj.scope == :class && obj.title == method_name
      end
    end
  end
end
