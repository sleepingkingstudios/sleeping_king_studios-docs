# frozen_string_literal: true

require 'sleeping_king_studios/docs/data'

module SleepingKingStudios::Docs::Data
  # Object representing a Ruby class.
  #
  # Each class can define the following elements:
  #
  # - Defined In files.
  # - inherited classes.
  # - extend-ed modules.
  # - include-ed modules.
  # - Definitions (classes and modules).
  # - Constants.
  # - Class attributes.
  # - Class methods.
  # - A constructor method.
  # - Instance attributes.
  # - Instance methods.
  # - Known subclasses.
  #
  # Additionally, a class can have a description and metadata tags.
  #
  # @see SleepingKingStudios::Docs::Data::Metadata
  # @see SleepingKingStudios::Docs::Data::ModuleObject
  class ClassObject < ModuleObject
    JSON_PROPERTIES = %i[
      direct_subclasses
      inherited_classes
    ].freeze
    private_constant :JSON_PROPERTIES

    # Generates a JSON-compatible representation of the module.
    #
    # Returns a Hash with the following keys:
    #
    # - 'name': The full, qualified name of the module.
    # - 'slug': The name of the module in url-safe format.
    # - 'files': A list of the files where the module is defined.
    # - 'short_description': A short description of the module.
    # - 'constructor': True if the class defines a constructor, otherwise false.
    #
    # Additionally, the returned Hash will conditionally include the following
    # keys, if the module defines at least one of the corresponding code
    # objects.
    #
    # - 'class_attributes': The class attributes, if any.
    # - 'class_methods': The class methods, if any.
    # - 'constants': The constants, if any.
    # - 'defined_classes': The defined Classes, if any.
    # - 'defined_modules': The defined Modules, if any.
    # - 'description': The full description of the module, minus the first
    #   clause.
    # - 'extended_modules': A list of the modules that extend the module.
    # - 'included_modules': A list of the modules that are included in the
    #   module.
    # - 'instance_attributes': The instance attributes, if any.
    # - 'instance_methods': The instance methods, if any.
    # - 'metadata': Additional metadata tags from the documentation.
    #
    # @return [Hash{String => Object}] the representation of the module.
    def as_json
      JSON_PROPERTIES.reduce(super.merge('constructor' => constructor?)) \
      do |memo, property_name|
        value = send(property_name)

        next memo if empty?(value)

        memo.update(property_name.to_s => value)
      end
    end

    # @return [Boolean] true if the class defines a constructor, otherwise
    #   false.
    def constructor?
      native.meths.any? { |meth| meth.name == :initialize }
    end

    # A list of the direct subclasses of the class.
    #
    # For each subclass, it returns a Hash with the following keys:
    #
    # - 'name': The name of the inherited class.
    # - 'slug': A url-safe, hyphen-separated representation of the name.
    # - 'path': The path to the data file for the class.
    #
    # @return [Array<Hash{String => String}>] the direct subclasses.
    def direct_subclasses
      registry
        .select do |obj|
          obj.type == :class && obj.inheritance_tree[1] == native
        end
        .map { |obj| format_inclusion(obj) }
        .sort_by { |hsh| hsh['name'] }
    end

    # A list of the classes that are inherited by the class.
    #
    # For each inherited Class, it returns a Hash with the following keys:
    #
    # - 'name': The name of the inherited class.
    # - 'slug': A url-safe, hyphen-separated representation of the name.
    # - 'path': The path to the data file for the class.
    #
    # @return [Array<Hash{String => String}>] the inherited classes.
    def inherited_classes
      @inherited_classes ||=
        native
        .inheritance_tree[1..]
        .map { |obj| format_inclusion(obj) }
    end

    # @return [String] the type of the namespace.
    def type
      'class'
    end
  end
end
