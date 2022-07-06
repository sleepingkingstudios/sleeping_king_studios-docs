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
  class NamespaceObject
    # @param native [YARD::CodeObjects::NamespaceObject] the YARD object
    #   representing the documented namespace.
    def initialize(native)
      @native = native
    end

    # Generates a JSON-compatible representation of the namespace.
    #
    # @return [Hash{String => Object}] the representation of the namespace.
    def as_json # rubocop:disable Metrics/MethodLength
      {
        'class_attributes'    => class_attributes,
        'class_methods'       => class_methods,
        'constants'           => constants,
        'defined_classes'     => defined_classes,
        'defined_modules'     => defined_modules,
        'instance_attributes' => instance_attributes,
        'instance_methods'    => instance_methods,
        'name'                => name,
        'slug'                => slug
      }
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
        .select do |obj|
          obj.type == :method && obj.sep == '::' && !obj.is_attribute?
        end
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

    # Finds the names of the Classes defined under this namespace, if any.
    #
    # @return [Array<String>] the names of the defined classes.
    def defined_classes
      @defined_classes ||=
        native
        .children
        .select { |obj| obj.type == :class }
        .map { |obj| obj.name.to_s }
        .sort
    end

    # Finds the names of the Modules defined under this namespace, if any.
    #
    # @return [Array<String>] the names of the defined modules.
    def defined_modules
      @defined_modules ||=
        native
        .children
        .select { |obj| obj.type == :module }
        .map { |obj| obj.name.to_s }
        .sort
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
        .select do |obj|
          obj.type == :method && obj.sep == '#' && !obj.is_attribute?
        end
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

    # The full, qualified name of the namespace in url-safe format.
    #
    # @return [String] the qualified name.
    def slug
      @slug ||= tools.string_tools.underscore(name).tr('_', '-')
    end

    private

    attr_reader :native

    def format_attribute(name, methods)
      {
        'name'  => name.to_s,
        'read'  => !methods[:read].nil?,
        'write' => !methods[:write].nil?
      }
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
