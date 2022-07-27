# frozen_string_literal: true

require 'sleeping_king_studios/yard/data'

module SleepingKingStudios::Yard::Data
  # Object representing a Ruby method.
  #
  # Each method has a name and a signature, and can define the following
  # elements:
  #
  # - Parameters.
  # - A return type.
  # - Raised exceptions.
  # - A yielded block.
  #
  # In addition, a method may have a short description, a full description, and
  # metadata.
  class MethodObject < SleepingKingStudios::Yard::Data::Base # rubocop:disable Metrics/ClassLength
    JSON_PROPERTIES = %i[
      description
      metadata
      options
      overloads
      params
      raises
      returns
      short_description
      yield_params
      yield_returns
      yields
    ].freeze
    private_constant :JSON_PROPERTIES

    PARAGRAPH_BREAK = /\n{2,}/.freeze
    private_constant :PARAGRAPH_BREAK

    # Generates a JSON-compatible representation of the method.
    #
    # Returns a Hash with the following keys:
    #
    # - 'name': The full, qualified name of the method.
    # - 'slug': The name of the method in url-safe format.
    # - 'signature': A String representation of the method and its parameters.
    # - 'short_description': A short description of the method.
    #
    # Additionally, the returned Hash will conditionally include the following
    # keys, if the method defines at least one of the corresponding code
    # objects.
    #
    # - 'description': The full description of the method, minus the first
    #   clause.
    # - 'metadata': Additional metadata tags from the documentation.
    # - 'params': The method's parameters, as documented.
    # - 'options': The method's option parameters, if any.
    # - 'raises': The exceptions raised by the method.
    # - 'returns': The method's return types and description.
    # - 'yields': The block yielded by the method.
    # - 'yieldparams': The yielded blocks' parameters.
    # - 'yieldreturn': The value returned by the block.
    #
    # Finally, the method may have one or more overloads, which replace or
    # supplement the method with alternative signatures or documentation.
    #
    # - 'overloads': The method overloads, if any. Each overload has the same
    #   keys as a full method object.
    #
    # @return [Hash{String => Object}] the representation of the method.
    def as_json
      JSON_PROPERTIES.reduce(required_json) do |memo, property_name|
        value = send(property_name)

        next memo if empty?(value)

        memo.update(property_name.to_s => value)
      end
    end

    # A short description of the method.
    #
    # The first part of the method description, separated by the first
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

    # The path to the data file.
    #
    # @return [String] the file path.
    def data_path
      @data_path ||= name.split('::').map { |str| slugify(str) }.join('/')
    end

    # The full description of the method, minus the first clause.
    #
    # The remainder of the method description, if any, after subtracting the
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

    # The full, qualified name of the method.
    #
    # @return [String] the qualified name.
    def name
      @name ||= native.path
    end

    # The documented options of the method.
    #
    # Each option is a Hash with the following keys:
    #
    # - 'name': The name of the parameter.
    # - 'type': The JSON representation of the parsed Type object.
    # - 'description': The description of the parameter.
    #
    # @return [Array<Hash>] the method options.
    def options
      @options ||=
        native
        .tags
        .select { |tag| tag.tag_name == 'option' }
        .map { |tag| format_option(tag) }
    end

    # The documented overloads for the method.
    #
    # Each overload is a JSON representation of a method, and includes the same
    # tags and properties (with the exception that an overload cannot itself
    # have overloads).
    #
    # @see #as_json
    def overloads
      native
        .tags
        .select { |tag| tag.tag_name == 'overload' }
        .map { |tag| format_overload(tag) }
    end

    # The documented parameters of the method.
    #
    # Each parameter is a Hash with the following keys:
    #
    # - 'name': The name of the parameter.
    # - 'type': The JSON representation of the parsed Type object.
    # - 'description': The description of the parameter.
    #
    # @return [Array<Hash>] the method parameters.
    def params
      @params ||=
        native
        .tags
        .select { |tag| tag.tag_name == 'param' }
        .map { |tag| format_param(tag) }
    end

    # The documented raised exceptions of the method.
    #
    # Each raised exception is a Hash with the following keys:
    #
    # - 'type': The type of exception raised.
    # - 'description': The description of the exception, or details on when the
    #   exception is raised.
    #
    # @return [Array<Hash>] the exceptions raised.by the method.
    def raises
      @raises ||=
        native
        .tags
        .select { |tag| tag.tag_name == 'raise' }
        .map { |tag| format_return(tag) }
    end

    # The return type or types of the method.
    #
    # Each return type or types is a Hash with the following keys:
    #
    # - 'type': The JSON representation of the parsed Type object.
    # - 'description': The description of the returned type, or details on when
    #   that type will be returned.
    #
    # @return [Array<Hash>] the return types of the method.
    #
    # @see SleepingKingStudios::Yard::Data::Types::Type.
    def returns
      @returns ||=
        native
        .tags
        .select { |tag| tag.tag_name == 'return' }
        .map { |tag| format_return(tag) }
    end

    # The name and parameters of the method.
    #
    # @return [String] the method signature.
    def signature
      @signature ||= native.signature
    end

    # The name of the method in url-safe format.
    #
    # @return [String] the method name.
    def slug
      @slug ||= slugify(name.split('::').last)
    end

    # The parameters of the yielded to the block.
    #
    # Each parameter is a Hash with the following keys:
    #
    # - 'name': The name of the parameter.
    # - 'type': The JSON representation of the parsed Type object.
    # - 'description': The description of the parameter.
    #
    # @return [Array<Hash>] the yielded parameters.
    def yield_params
      @yield_params ||=
        native
        .tags
        .select { |tag| tag.tag_name == 'yieldparam' }
        .map { |tag| format_yield_param(tag) }
    end

    # The return type or types of the yielded block.
    #
    # Each return type or types is a Hash with the following keys:
    #
    # - 'type': The JSON representation of the parsed Type object.
    # - 'description': The description of the returned type, or details on when
    #   that type will be returned.
    #
    # @return [Array<Hash>] the return types of the yielded block.
    #
    # @see SleepingKingStudios::Yard::Data::Types::Type.
    def yield_returns
      @yield_returns ||=
        native
        .tags
        .select { |tag| tag.tag_name == 'yieldreturn' }
        .map { |tag| format_return(tag) }
    end

    # The yielded block or blocks of method.
    #
    # Each yielded block is a Hash with the following keys:
    #
    # - 'description': The description of the yielded block or details on when
    #   the block will be yielded.
    # - 'parameters': (Optional) The parameters yielded to the block.
    #
    # @return [Array<Hash>] the yielded blocks.
    #
    # @see #yieldparams
    # @see #yieldreturns
    def yields
      native
        .tags
        .select { |tag| tag.tag_name == 'yield' }
        .map { |tag| format_yield(tag) }
    end

    private

    def format_metadata
      SleepingKingStudios::Yard::Data::Metadata
        .new(native: native, registry: registry)
        .as_json
    end

    def format_option(tag)
      {
        'description' => tag.pair.text,
        'name'        => tag.name,
        'tag_name'    => tag.pair.name,
        'type'        => parse_types(tag.pair)
      }
    end

    def format_overload(tag)
      self.class.new(native: tag, registry: registry).as_json
    end

    def format_param(tag)
      json = {
        'description' => tag.text,
        'name'        => tag.name,
        'type'        => parse_types(tag)
      }

      return json unless parameter_defaults.key?(tag.name)

      json.merge('default' => parameter_defaults[tag.name])
    end

    def format_return(tag)
      {
        'description' => tag.text,
        'type'        => parse_types(tag)
      }
    end

    def format_yield(tag)
      json = { 'description' => tag.text }

      return json unless tag.types

      json.merge('parameters' => tag.types)
    end

    def format_yield_param(tag)
      json = {
        'description' => tag.text,
        'name'        => tag.name,
        'type'        => parse_types(tag)
      }

      return json unless yield_defaults.key?(tag.name)

      json.merge('default' => yield_defaults[tag.name])
    end

    def parse_types(tag)
      tag.types.reduce([]) do |memo, type|
        memo + type_parser.parse(type).map(&:as_json)
      end
    end

    def parameter_defaults
      @parameter_defaults ||=
        native
        .signature[(5 + native.name.size)..-2]
        .split(', ')
        .map { |param| param.split(/ = |: ?/) }
        .select { |tuple| tuple.size == 2 }
        .to_h
    end

    def yield_defaults
      yield_tag = native.tags.find { |tag| tag.tag_name == 'yield' }

      return {} unless yield_tag

      @yield_defaults ||=
        yield_tag
        .types
        .map { |param| param.split(/ = |: ?/) }
        .select { |tuple| tuple.size == 2 }
        .to_h
    end

    def required_json
      {
        'name'      => name,
        'signature' => signature,
        'slug'      => slug
      }
    end

    def split_docstring
      match = native.docstring.match(PARAGRAPH_BREAK)

      return native.docstring.to_s unless match

      [match.pre_match.to_s, match.post_match.to_s]
    end

    def type_parser
      @type_parser ||=
        SleepingKingStudios::Yard::Data::Types::Parser
        .new(registry: registry)
    end
  end
end
