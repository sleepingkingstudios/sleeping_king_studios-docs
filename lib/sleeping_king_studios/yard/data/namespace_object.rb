# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'

require 'sleeping_king_studios/yard/data'

module SleepingKingStudios::Yard::Data
  # Object representing a Ruby namespace.
  #
  # Each namespace can define the following elements:
  #
  # - Definitions (classes and modules).
  # - Constants.
  # - Class attributes.
  # - Class methods.
  # - Instance attributes.
  # - Instance methods.
  #
  # In most cases, there should be one documented namespace, reflecting the
  # top-level namespace, and in most cases should only include defined classes
  # and/or modules. Top-level constants may be required on a case-by-case basis.
  #
  # All other namespace properties (attributes and methods) should be reserved
  # for classes and modules, whose representation inherits from NamespaceObject.
  #
  # @see SleepingKingStudios::Yard::Data::ClassObject
  # @see SleepingKingStudios::Yard::Data::ModuleObject
  class NamespaceObject < SleepingKingStudios::Yard::Data::Base # rubocop:disable Metrics/ClassLength
    JSON_PROPERTIES = %i[
      class_attributes
      class_methods
      constants
      defined_classes
      defined_modules
      instance_attributes
      instance_methods
    ].freeze
    private_constant :JSON_PROPERTIES

    def initialize
      root =
        SleepingKingStudios::Yard::Registry
        .instance
        .find { |obj| obj.name == :root }

      super(native: root)
    end

    # Generates a JSON-compatible representation of the namespace.
    #
    # Returns a Hash with the following keys:
    #
    # - 'name': The full, qualified name of the namespace.
    # - 'slug': The name of the namespace in url-safe format.
    #
    # Additionally, the returned Hash will conditionally include the following
    # keys, if the namespace defines at least one of the corresponding code
    # objects.
    #
    # - 'class_attributes': The class attributes, if any.
    # - 'class_methods': The class methods, if any.
    # - 'constants': The constants, if any.
    # - 'defined_classes': The defined Classes, if any.
    # - 'defined_modules': The defined Modules, if any.
    # - 'instance_attributes': The instance attributes, if any.
    # - 'instance_methods': The instance methods, if any.
    #
    # @return [Hash{String => Object}] the representation of the namespace.
    def as_json
      JSON_PROPERTIES.reduce(required_json) do |memo, property_name|
        value = send(property_name)

        next memo if empty?(value)

        memo.update(property_name.to_s => value)
      end
    end

    # Finds the class attributes defined for the namespace.
    #
    # For each class attribute, it returns a Hash with the following keys:
    #
    # - 'name': The name of the attribute.
    # - 'read': True if the attribute defines a reader method.
    # - 'write': True if the attribute defines a writer method.
    #
    # @return [Array<Hash>] the class attributes.
    def class_attributes
      @class_attributes ||=
        native
        .class_attributes
        .map { |name, methods| format_attribute(name, methods) }
        .sort_by { |hsh| hsh['name'] }
    end

    # Finds the names of the class methods defined for the namespace.
    #
    # @return [Array<String>] the names of the class methods.
    def class_methods
      @class_methods ||=
        native
        .meths
        .select { |obj| obj.scope == :class && !obj.is_attribute? }
        .map { |obj| obj.name.to_s }
        .sort
    end

    # Finds the names of the constants defined under this namespace.
    #
    # @return [Array<String>] the names of the constants.
    def constants
      @constants ||=
        native
        .constants
        .map { |obj| obj.name.to_s }
        .sort
    end

    # Finds the Classes defined under this namespace, if any.
    #
    # For each defined Class, it returns a Hash with the following keys:
    #
    # - 'name': The name of the defined Class.
    # - 'slug': A url-safe, hyphen-separated representation of the name.
    #
    # @example
    #   # Given a class LaunchWindow in the namespace Space::Operations:
    #   namespace.name
    #   #=> 'Space::Operations'
    #   namespace.defined_classes
    #   #=> [{ 'name' => 'LaunchWindow', 'slug' => 'launch-window' }]
    #
    # @return [Array<Hash>] the defined classes.
    def defined_classes
      @defined_classes ||=
        native
        .children
        .select { |obj| obj.type == :class }
        .map { |obj| format_definition(obj) }
        .sort_by { |hsh| hsh['name'] }
    end

    # Finds the Modules defined under this namespace, if any.
    #
    # For each defined Module, it returns a Hash with the following keys:
    #
    # - 'name': The name of the defined Module.
    # - 'slug': A url-safe, hyphen-separated representation of the name.
    #
    # @example
    #   # Given a class FuelConsumer in the namespace Space::Engineering:
    #   namespace.name
    #   #=> 'Space::Engineering'
    #   namespace.defined_classes
    #   #=> [{ 'name' => 'FuelConsumer', 'slug' => 'fuel-consumer' }]
    #
    # @return [Array<Hash>] the defined modules.
    def defined_modules
      @defined_modules ||=
        native
        .children
        .select { |obj| obj.type == :module }
        .map { |obj| format_definition(obj) }
        .sort_by { |hsh| hsh['name'] }
    end

    # Finds the instance attributes defined for the namespace.
    #
    # For each instance attribute, it returns a Hash with the following keys:
    #
    # - 'name': The name of the attribute.
    # - 'read': True if the attribute defines a reader method.
    # - 'write': True if the attribute defines a writer method.
    #
    # @return [Array<Hash>] the instance attributes.
    def instance_attributes
      @instance_attributes ||=
        native
        .instance_attributes
        .map { |name, methods| format_attribute(name, methods) }
        .sort_by { |hsh| hsh['name'] }
    end

    # Finds the names of the instance methods defined for the namespace.
    #
    # @return [Array<String>] the names of the instance methods.
    def instance_methods
      @instance_methods ||=
        native
        .meths
        .select { |obj| obj.scope == :instance && !obj.is_attribute? }
        .map { |obj| obj.name.to_s }
        .sort
    end

    # The full, qualified name of the namespace.
    #
    # For the root namespace, should return an empty string. For a Class or a
    # Module, should return the full name, e.g. "MyGem::MyModule::MyClass".
    #
    # @return [String] the qualified name.
    def name
      @name ||= native.path
    end

    # The name of the namespace in url-safe format.
    #
    # @return [String] the namespace name.
    def slug
      @slug ||= slugify(name.split('::').last || '')
    end

    private

    def format_attribute(name, methods)
      {
        'name'  => name.to_s,
        'read'  => !methods[:read].nil?,
        'write' => !methods[:write].nil?
      }
    end

    def format_definition(obj)
      {
        'name' => obj.name.to_s,
        'slug' => slugify(obj.name)
      }
    end

    def required_json
      {
        'name' => name,
        'slug' => slug
      }
    end
  end
end
