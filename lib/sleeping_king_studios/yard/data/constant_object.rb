# frozen_string_literal: true

require 'sleeping_king_studios/yard/data'

module SleepingKingStudios::Yard::Data
  # Object representing a Ruby constant.
  #
  # Each constant has a name and a value. In addition, a constant may have a
  # short description, a full description, and metadata.
  class ConstantObject < SleepingKingStudios::Yard::Data::Base
    JSON_PROPERTIES = %i[
      data_path
      description
      metadata
    ].freeze
    private_constant :JSON_PROPERTIES

    PARAGRAPH_BREAK = /\n{2,}/.freeze
    private_constant :PARAGRAPH_BREAK

    # Generates a JSON-compatible representation of the constant.
    #
    # Returns a Hash with the following keys:
    #
    # - 'name': The full, qualified name of the constant.
    # - 'slug': The name of the constant in url-safe format.
    # - 'value': A String representation of the value of the constant.
    # - 'short_description': A short description of the constant.
    #
    # Additionally, the returned Hash will conditionally include the following
    # keys, if the constant defines at least one of the corresponding code
    # objects.
    #
    # - 'description': The full description of the constant, minus the first
    #   clause.
    # - 'metadata': Additional metadata tags from the documentation.
    #
    # @return [Hash{String => Object}] the representation of the constant.
    def as_json
      JSON_PROPERTIES.reduce(required_json) do |memo, property_name|
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

    # The full description of the constant, minus the first clause.
    #
    # The remainder of the constant description, if any, after subtracting the
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

    # Additional metadata tags from the documentation.
    #
    # @see SleepingKingStudios::Yard::Data::Metadata.
    def metadata
      @metadata ||= format_metadata
    end

    # The full, qualified name of the constant.
    #
    # @return [String] the qualified name.
    def name
      @name ||= native.path
    end

    # A short description of the constant.
    #
    # The first part of the constant description, separated by the first
    # paragraph break. Typically should fit on a single line of text.
    #
    # @return [String] the short description.
    #
    # @see #description.
    def short_description
      return @short_description if @short_description

      @short_description, @description = split_docstring

      @short_description
    end

    # The name of the constant in url-safe format.
    #
    # @return [String] the constant name.
    def slug
      @slug ||= slugify(name.split('::').last)
    end

    # A String representation of the value of the constant.
    #
    # @return [String] the constant value.
    def value
      native.value
    end

    private

    def required_json
      {
        'name'              => name,
        'slug'              => slug,
        'short_description' => short_description,
        'value'             => value
      }
    end

    def format_metadata
      SleepingKingStudios::Yard::Data::Metadata
        .new(native: native)
        .as_json
    end

    def split_docstring
      match = native.docstring.match(PARAGRAPH_BREAK)

      return native.docstring.to_s unless match

      [match.pre_match.to_s, match.post_match.to_s]
    end
  end
end
