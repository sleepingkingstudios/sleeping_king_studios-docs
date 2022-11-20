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
      constructor
      data_path
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

    NAME_SEPARATOR = /::|#|\./.freeze
    private_constant :NAME_SEPARATOR

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
      JSON_PROPERTIES
        .reduce(required_json) do |memo, property_name|
          value = send(property_name)

          next memo if empty?(value)

          memo.update(property_name.to_s => value)
        end
        .then { |json| merge_pure_overload(json) }
    end

    # @return [Boolean] true if the method is a class method; otherwise false.
    def class_method?
      !instance_method?
    end

    # @return [Boolean] true if the method is a constructor; otherwise false.
    def constructor?
      native.constructor?
    end
    alias constructor constructor?

    # The path to the data file.
    #
    # @return [String] the file path.
    def data_path
      return @data_path if @data_path

      *scope_names, method_name =
        name.split(NAME_SEPARATOR).reject(&:empty?)

      scope_names = scope_names.map { |str| slugify(str) }
      scope_names << "#{instance_method? ? 'i' : 'c'}-#{slugify(method_name)}"

      @data_path = scope_names.join('/')
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

    # @return [Boolean] true if the method is an instance method; otherwise
    #   false.
    def instance_method?
      native.path[-(1 + native.name.length)] == '#'
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
        .group_by(&:name)
        .map { |name, tags| format_options(name, tags) }
    end

    # Checks if the method has been completely overloaded.
    #
    # A completely overloaded method has no description and no tags other than
    # exactly one @overload tag. This case is common when documenting a method
    # with a different signature.
    #
    # @return [true, false] true if the method is completely overloaded;
    #   otherwise false.
    def overloaded?
      return false unless native.docstring.empty?

      return false unless native.tags.all? { |tag| tag.tag_name == 'overload' }

      native.tags.size == 1
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

    # The path to the defining class or module's data file.
    #
    # @return [String] the file path.
    def parent_path
      return @parent_path if @parent_path

      return @parent_path = '' if native.parent.root?

      parent_class  =
        if native.parent.is_a?(YARD::CodeObjects::ClassObject)
          SleepingKingStudios::Yard::Data::ClassObject
        else
          SleepingKingStudios::Yard::Data::ModuleObject
        end
      parent_object = parent_class.new(native: native.parent)

      @parent_path = parent_object.data_path
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

    # The name and parameters of the method.
    #
    # @return [String] the method signature.
    def signature
      return @signature if @signature

      unless native.signature.include?('(')
        return @signature = native.signature.sub(/\Adef /, '')
      end

      @signature = generate_signature
    end

    # The name of the method in url-safe format.
    #
    # @return [String] the method name.
    def slug
      @slug ||= slugify(name.sub(/\A::/, '').split(/#|\./).last)
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

    def extract_parameters
      native
        .signature
        .sub(/\A(def )?#{Regexp.escape(native.name)}\(/, '')
        .split(')')
        .first
    end

    def extract_yield_parameters
      return '' unless native.signature.match?(/\) *{/)

      native
        .signature
        .split(')')
        .last
        .sub(/\A ?\{ ?\|/, '')
        .sub(/\| ?\}\z/, '')
    end

    def format_metadata
      SleepingKingStudios::Yard::Data::Metadata
        .new(native: native)
        .as_json
    end

    def format_option(tag)
      {
        'description' => tag.pair.text,
        'name'        => tag.pair.name,
        'type'        => parse_types(tag.pair)
      }
    end

    def format_options(name, tags)
      {
        'name' => name,
        'opts' => tags.map { |tag| format_option(tag) }
      }
    end

    def format_overload(tag)
      self
        .class
        .new(native: tag)
        .as_json
        .tap { |hsh| hsh.delete('data_path') }
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

    def generate_signature
      params = extract_parameters
      yields = extract_yield_parameters
      buffer = "#{native.name}(#{strip_rubocop_directives(params)})"

      return buffer if yields.empty?

      "#{buffer} { |#{strip_rubocop_directives(yields)}| }"
    end

    def merge_pure_overload(json)
      return json unless overloaded?

      overload = json.delete('overloads').first

      json.merge(overload)
    end

    def parse_types(tag)
      (tag.types || []).reduce([]) do |memo, type|
        memo + type_parser.parse(type).map(&:as_json)
      end
    end

    def parameter_defaults
      return @parameter_defaults if @parameter_defaults

      return @parameter_defaults = {} unless signature.include?('(')

      @parameter_defaults ||=
        signature[(1 + native.name.size)...-1]
        .split(', ')
        .map { |param| param.split(/ = |: ?/) }
        .select { |tuple| tuple.size == 2 }
        .to_h
    end

    def required_json
      {
        'name'        => name,
        'parent_path' => parent_path,
        'signature'   => signature,
        'slug'        => slug
      }
    end

    def rubocop_directive?(str)
      return true if str == 'rubocop:disable'

      str.include? '/'
    end

    def split_docstring
      match = native.docstring.match(PARAGRAPH_BREAK)

      return native.docstring.to_s unless match

      [match.pre_match.to_s, match.post_match.to_s]
    end

    def strip_rubocop_directives(parameters)
      return '' if parameters.nil?

      parameters
        .split(/, +/)
        .map { |segment| strip_rubocop_directives_from_segment(segment) }
        .reject(&:empty?)
        .join(', ')
    end

    def strip_rubocop_directives_from_segment(segment)
      segment
        .strip
        .split(/ +/)
        .reject { |str| str == '#' || rubocop_directive?(str) }
        .join(' ')
    end

    def type_parser
      @type_parser ||=
        SleepingKingStudios::Yard::Data::Types::Parser.new
    end

    def yield_defaults # rubocop:disable Metrics/CyclomaticComplexity
      yield_tag = native.tags.find { |tag| tag.tag_name == 'yield' }

      return {} unless yield_tag

      @yield_defaults ||=
        yield_tag
        .types
        &.map { |param| param.split(/ = |: ?/) }
        &.select { |tuple| tuple.size == 2 }
        .to_h
    end
  end
end
