# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/types'

module SleepingKingStudios::Yard::Data::Types
  # Parses a YARD type list into a nested data object.
  #
  # @see https://www.rubydoc.info/gems/yard/file/docs/Tags.md#types-specifier-list
  class Parser # rubocop:disable Metrics/ClassLength
    PARAMETERIZED_CHARS = {
      array:       '">"',
      hash_keys:   '"=>"',
      hash_values: '"}"'
    }.freeze
    private_constant :PARAMETERIZED_CHARS

    PARAMETERIZED_TYPES = {
      array:       'parameterized type',
      hash_keys:   'key-value type',
      hash_values: 'key-value type'
    }.freeze
    private_constant :PARAMETERIZED_TYPES

    # Exception raised when encountering an invalid type string.
    class ParseError < StandardError; end

    # @param registry [Enumerable] the YARD registry.
    def initialize(registry:)
      @registry = registry
    end

    # Parses a YARD type list.
    #
    # @return [Array<[SleepingKingStudios::Yard::Data::Types::Type]>] the parsed
    #   types.
    def parse(type)
      return [] if type.nil? || type.empty?

      parse_types(type)
    end

    private

    attr_reader :registry

    def append_item(stack:, token:)
      *stack, parent, context = stack

      context = context.merge(name: token.strip) unless context.key?(:name)
      parent  = parent.merge(
        values: parent[:values] + [build_type(**context)]
      )

      [*stack, parent]
    end

    def build_array(name:, values:, ordered: false)
      SleepingKingStudios::Yard::Data::Types::ParameterizedType.new(
        items:    values,
        name:     name,
        ordered:  ordered,
        registry: registry
      )
    end

    def build_basic(name:)
      SleepingKingStudios::Yard::Data::Types::Type.new(
        name:     name,
        registry: registry
      )
    end

    def build_hash(name:, keys:, values:)
      SleepingKingStudios::Yard::Data::Types::KeyValueType.new(
        keys:     keys,
        name:     name,
        registry: registry,
        values:   values
      )
    end

    def build_type(name:, type: nil, **options)
      case type
      when :array
        build_array(name: name, **options)
      when :hash_values
        build_hash(name: name, **options)
      when nil
        build_basic(name: name, **options)
      else
        # :nocov:
        raise ParseError, "unable to build type #{type.inspect}"
        # :nocov:
      end
    end

    def close_array(offset:, stack:, token:)
      parent = stack[-2]

      unless parent[:type] == :array
        message = '">" must terminate a parameterized type'

        raise ParseError,
          invalid_character(char: '>', offset: offset, message: message)
      end

      stack = append_item(stack: stack, token: token)

      [stack, '', offset + 1]
    end

    def close_hash(offset:, stack:, token:) # rubocop:disable Metrics/MethodLength
      parent = stack[-2]

      if parent[:type] == :hash_keys
        raise ParseError, unclosed_parameterized_type(parent[:type])
      end

      unless parent[:type] == :hash_values
        message = '"}" must terminate a key-value type'

        raise ParseError,
          invalid_character(char: '}', offset: offset, message: message)
      end

      stack = append_item(stack: stack, token: token)

      [stack, '', offset + 1]
    end

    def close_item(offset:, stack:, token:)
      stack = append_item(stack: stack, token: token) + [{}]

      [stack, '', offset + 1]
    end

    def close_ordered(offset:, stack:, str:, token:)
      parent = stack[-2]

      unless parent[:type] == :array && str[offset + 1] == '>'
        message = '")>" must terminate an order-dependent list'

        raise ParseError,
          invalid_character(char: ')', offset: offset, message: message)
      end

      stack = append_item(stack: stack, token: token)

      [stack, '', offset + 2]
    end

    def invalid_character(char:, offset:, message: nil)
      return "invalid character `#{char}' at index #{offset}" unless message

      "invalid character `#{char}' at index #{offset}: #{message}"
    end

    def open_array(offset:, stack:, str:, token:) # rubocop:disable Metrics/MethodLength
      *stack, context = stack

      if token.empty?
        message = '"<" must follow a token name'

        raise ParseError,
          invalid_character(char: '<', offset: offset, message: message)
      end

      ordered = str[offset + 1] == '('
      context = context.merge(
        name:    token.strip,
        type:    :array,
        ordered: ordered,
        values:  []
      )
      stack   = [*stack, context, {}]

      [stack, '', offset + (ordered ? 2 : 1)]
    end

    def open_hash(offset:, stack:, token:) # rubocop:disable Metrics/MethodLength
      *stack, context = stack

      if token.empty?
        message = '"{" must follow a token name'

        raise ParseError,
          invalid_character(char: '{', offset: offset, message: message)
      end

      context = context.merge(
        name:   token.strip,
        type:   :hash_keys,
        values: []
      )
      stack   = [*stack, context, {}]

      [stack, '', offset + 1]
    end

    def parse_char(offset:, stack:, str:, token:) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      char = str[offset]

      case char
      when '<'
        open_array(offset: offset, stack: stack, str: str, token: token)
      when '>'
        close_array(offset: offset, stack: stack, token: token)
      when '('
        message = '"<(" must start an order-dependent list'

        raise ParseError,
          invalid_character(char: '(', offset: offset, message: message)
      when ')'
        close_ordered(offset: offset, stack: stack, str: str, token: token)
      when '{'
        open_hash(offset: offset, stack: stack, token: token)
      when '}'
        close_hash(offset: offset, stack: stack, token: token)
      when '='
        switch_hash(offset: offset, stack: stack, str: str, token: token)
      when ','
        close_item(offset: offset, stack: stack, token: token)
      else
        [stack, token + char, offset + 1]
      end
    end

    def parse_types(str) # rubocop:disable Metrics/MethodLength
      token  = ''
      stack  = [{ type: :top, values: [] }, {}]
      offset = 0

      while offset < str.size
        stack, token, offset = parse_char(
          offset: offset,
          stack:  stack,
          str:    str,
          token:  token
        )
      end

      stack = append_item(stack: stack, token: token)

      unless stack.last[:type] == :top
        raise ParseError, unclosed_parameterized_type(stack.last[:type])
      end

      stack.last[:values]
    end

    def switch_hash(offset:, stack:, str:, token:) # rubocop:disable Metrics/MethodLength
      parent = stack[-2]

      unless parent[:type] == :hash_keys && str[offset + 1] == '>'
        message = '"=>" must separate hash keys and values'

        raise ParseError,
          invalid_character(char: '=', offset: offset, message: message)
      end

      *stack, parent = append_item(stack: stack, token: token)

      parent = parent.merge(
        type:   :hash_values,
        keys:   parent[:values],
        values: []
      )
      stack = [*stack, parent, {}]

      [stack, '', offset + 2]
    end

    def unclosed_parameterized_type(type)
      "unterminated #{PARAMETERIZED_TYPES[type]} - is there a missing " \
        "#{PARAMETERIZED_CHARS[type]} character?"
    end
  end
end
