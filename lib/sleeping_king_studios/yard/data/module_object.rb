# frozen_string_literal: true

require 'sleeping_king_studios/yard/data'

module SleepingKingStudios::Yard::Data
  # Object representing a Ruby module.
  #
  # Each module can define the following elements:
  #
  # - Defined In files.
  # - extend-ed modules.
  # - include-ed modules.
  # - Definitions (classes and modules).
  # - Constants.
  # - Class attributes.
  # - Class methods.
  # - Instance attributes.
  # - Instance methods.
  #
  # Additionally, a module can have a description and metadata tags.
  #
  # @see SleepingKingStudios::Yard::Data::ClassObject
  # @see SleepingKingStudios::Yard::Data::Metadata
  # @see SleepingKingStudios::Yard::Data::NamespaceObject
  class ModuleObject < NamespaceObject
    JSON_PROPERTIES = %i[
      data_path
      description
      extended_modules
      included_modules
      metadata
    ].freeze
    private_constant :JSON_PROPERTIES

    PARAGRAPH_BREAK = /\n{2,}/.freeze
    private_constant :PARAGRAPH_BREAK

    # Generates a JSON-compatible representation of the module.
    #
    # Returns a Hash with the following keys:
    #
    # - 'name': The full, qualified name of the module.
    # - 'slug': The name of the module in url-safe format.
    # - 'files': A list of the files where the module is defined.
    # - 'short_description': A short description of the module.
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
      JSON_PROPERTIES.reduce(super) do |memo, property_name|
        value = send(property_name)

        next memo if empty?(value)

        memo.update(property_name.to_s => value)
      end
    end

    # The path to the data file.
    #
    # @return [String] the file path.
    def data_path
      @data_path ||= name.split('::').map { |str| slugify(str) }.join('/')
    end

    # The full description of the module, minus the first clause.
    #
    # The remainder of the module description, if any, after subtracting the
    # short description (separated by the first paragraph break).
    #
    # @return [String] the remaining description.
    #
    # @see #short_description.
    def description
      return @description if @description

      @short_description, @description = split_docstring

      @description
    end

    # A list of the modules that extend the original module.
    #
    # For each extending Module, it returns a Hash with the following keys:
    #
    # - 'name': The name of the extending module.
    # - 'slug': A url-safe, hyphen-separated representation of the name.
    # - 'path': The path to the data file for the module.
    #
    # @return [Array<Hash{String => String}>] the extended modules.
    def extended_modules
      @extended_modules ||=
        native
        .class_mixins
        .map { |obj| format_inclusion(obj) }
        .sort_by { |hsh| hsh['name'] }
    end

    # A list of the files where the module is defined.
    #
    # @return [Array<String>] the list of files.
    def files
      @files ||= native.files.map(&:first)
    end

    # A list of the modules that are included in the original module.
    #
    # For each included Module, it returns a Hash with the following keys:
    #
    # - 'name': The name of the included module.
    # - 'slug': A url-safe, hyphen-separated representation of the name.
    # - 'path': The path to the data file for the module.
    #
    # @return [Array<Hash{String => String}>] the included modules.
    def included_modules
      @included_modules ||=
        native
        .instance_mixins
        .map { |obj| format_inclusion(obj) }
        .sort_by { |hsh| hsh['name'] }
    end

    # Additional metadata tags from the documentation.
    #
    # @see SleepingKingStudios::Yard::Data::Metadata.
    def metadata
      @metadata ||= format_metadata
    end

    # A short description of the module.
    #
    # The first part of the module description, separated by the first paragraph
    # break. Typically should fit on a single line of text.
    #
    # @return [String] the short description.
    #
    # @see #description.
    def short_description
      return @short_description if @short_description

      @short_description, @description = split_docstring

      @short_description
    end

    # @return [String] the type of the namespace.
    def type
      'module'
    end

    private

    def format_inclusion(obj)
      json = {
        'name' => obj.path,
        'slug' => slugify(obj.name)
      }

      return json unless registry.include?(obj)

      json.merge(
        'path' => obj.path.split('::').map { |str| slugify(str) }.join('/')
      )
    end

    def format_metadata
      SleepingKingStudios::Yard::Data::Metadata
        .new(native: native)
        .as_json
    end

    def inherited_constant?(constant_object)
      constant_object.data_path != "#{data_path}/#{constant_object.slug}"
    end

    def inherited_method?(method_object)
      !method_object.data_path.match?(
        %r{\A#{data_path}/(c|i)-#{method_object.slug}\z}
      )
    end

    def required_json
      super.merge(
        'files'             => files,
        'short_description' => short_description
      )
    end

    def split_docstring
      match = native.docstring.match(PARAGRAPH_BREAK)

      return native.docstring.to_s unless match

      [match.pre_match.to_s, match.post_match.to_s]
    end
  end
end
