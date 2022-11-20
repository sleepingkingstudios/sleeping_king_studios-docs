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
  # @see SleepingKingStudios::Yard::Data::RootObject
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
    # - 'path': The path to the reader method data file, or the writer method
    #   data file if the attribute does not define a reader method.
    #
    # @return [Array<Hash>] the class attributes.
    def class_attributes
      @class_attributes ||=
        find_class_attributes(native)
        .map { |name, options| format_attribute(name, options) }
        .compact
        .sort_by { |hsh| hsh['name'] }
    end

    # Finds the class methods defined for the namespace.
    #
    # For each method, it returns a Hash with the following keys:
    #
    # - 'name': The name of the method, including trailing characters such as
    #   `=' or `?'.
    # - 'path': The path to the method data file.
    #
    # @return [Array<Hash{String => String}>] the documented class methods.
    def class_methods
      @class_methods ||=
        native
        .meths
        .select { |obj| obj.scope == :class && !obj.is_attribute? }
        .reject { |obj| private_method?(obj) }
        .map { |obj| format_method(obj) }
        .sort_by { |hsh| hsh['name'] }
    end

    # Finds the names of the constants defined under this namespace.
    #
    # @return [Array<String>] the names of the constants.
    def constants
      @constants ||=
        native
        .constants
        .reject { |obj| private_constant?(obj) }
        .map { |obj| format_constant(obj) }
        .sort_by { |hsh| hsh['name'] }
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
        .reject { |obj| private_definition?(obj) }
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
        .reject { |obj| private_definition?(obj) }
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
    # - 'path': The path to the reader method data file, or the writer method
    #   data file if the attribute does not define a reader method.
    #
    # @return [Array<Hash>] the instance attributes.
    def instance_attributes
      @instance_attributes ||=
        find_instance_attributes(native)
        .map { |name, options| format_attribute(name, options) }
        .compact
        .sort_by { |hsh| hsh['name'] }
    end

    # Finds the instance methods defined for the namespace.
    #
    # For each method, it returns a Hash with the following keys:
    #
    # - 'name': The name of the method, including trailing characters such as
    #   `=' or `?'.
    # - 'path': The path to the method data file.
    #
    # @return [Array<Hash{String => String}>] the documented instance methods.
    def instance_methods
      @instance_methods ||=
        native
        .meths
        .select { |obj| obj.scope == :instance && !obj.is_attribute? }
        .reject { |obj| private_method?(obj) }
        .map { |obj| format_method(obj) }
        .sort_by { |hsh| hsh['name'] }
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

    # @return [String] the type of the namespace.
    def type
      'namespace'
    end

    private

    def find_class_attributes(native_object) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      attributes = {}

      if native_object.is_a?(YARD::CodeObjects::ClassObject)
        ancestors  = native_object.inheritance_tree - [native_object]
        attributes = ancestors.reverse.reduce(attributes) do |hsh, obj|
          next hsh if obj.is_a?(YARD::CodeObjects::Proxy)

          hsh.merge(find_class_attributes(obj))
        end
      end

      attributes = native_object.class_mixins.reverse.reduce(attributes) \
      do |hsh, obj|
        next hsh if obj.is_a?(YARD::CodeObjects::Proxy)

        hsh.merge(find_instance_attributes(obj))
      end

      attributes
        .transform_values { |attribute| attribute.merge(inherited: true) }
        .merge(native_object.class_attributes)
    end

    def find_instance_attributes(native_object) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      attributes = {}

      if native_object.is_a?(YARD::CodeObjects::ClassObject)
        ancestors  = native_object.inheritance_tree - [native_object]
        attributes = ancestors.reverse.reduce(attributes) do |hsh, obj|
          next hsh if obj.is_a?(YARD::CodeObjects::Proxy)

          hsh.merge(find_instance_attributes(obj))
        end
      end

      attributes = native_object.instance_mixins.reverse.reduce(attributes) \
      do |hsh, obj|
        next hsh if obj.is_a?(YARD::CodeObjects::Proxy)

        hsh.merge(find_instance_attributes(obj))
      end

      attributes
        .transform_values { |attribute| attribute.merge(inherited: true) }
        .merge(native_object.instance_attributes)
    end

    def format_attribute(name, options) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return nil unless public_attribute?(options)

      method_object =
        SleepingKingStudios::Yard::Data::MethodObject
        .new(native: options.values.find { |method| !method.nil? })

      {
        'name'      => name.to_s,
        'read'      => !options[:read].nil?,
        'write'     => !options[:write].nil?,
        'path'      => method_object.data_path,
        'slug'      => method_object.slug,
        'inherited' => !!options[:inherited] # rubocop:disable Style/DoubleNegation
      }
    end

    def format_constant(native_constant)
      constant_object =
        SleepingKingStudios::Yard::Data::ConstantObject
        .new(native: native_constant)

      {
        'name'      => native_constant.name.to_s,
        'path'      => constant_object.data_path,
        'slug'      => constant_object.slug,
        'inherited' => inherited_constant?(constant_object)
      }
    end

    def format_definition(obj)
      {
        'name' => obj.name.to_s,
        'slug' => slugify(obj.name)
      }
    end

    def format_method(native_method) # rubocop:disable Metrics/MethodLength
      method_object =
        SleepingKingStudios::Yard::Data::MethodObject
        .new(native: native_method)
      hsh           = {
        'name'      => native_method.name.to_s,
        'path'      => method_object.data_path,
        'slug'      => method_object.slug,
        'inherited' => inherited_method?(method_object)
      }

      return hsh unless method_object.constructor?

      hsh.merge('constructor' => true)
    end

    def inherited_constant?(_constant_object)
      false
    end

    def inherited_method?(_method_object)
      false
    end

    def private_constant?(constant_object)
      return true unless constant_object.visibility == :public

      constant_object.tags.any? { |tag| tag.tag_name == 'private' }
    end

    def private_definition?(definition_object)
      definition_object.tags.any? { |tag| tag.tag_name == 'private' }
    end

    def private_method?(method_object)
      return true unless method_object.visibility == :public

      method_object.tags.any? { |tag| tag.tag_name == 'private' }
    end

    def public_attribute?(options)
      options
        .values
        .select { |value| value.is_a?(YARD::CodeObjects::MethodObject) }
        .any? { |obj| !private_method?(obj) }
    end

    def required_json
      {
        'name' => name,
        'slug' => slug,
        'type' => type
      }
    end
  end
end
