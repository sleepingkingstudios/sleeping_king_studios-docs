# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'
require 'treetop'

require 'sleeping_king_studios/docs/data/types'
require 'sleeping_king_studios/docs/data/types/grammar'

module SleepingKingStudios::Docs::Data::Types
  # Parses a YARD type list into a nested data object.
  #
  # @note Certain combinations of comparable methods and parameterized types are
  #   known not to parse: list types with `#<=` or `#>` methods, and hash types
  #   with `#<`, `#==`, or `#>` keys. As a workaround, add trailing whitespace
  #   between the method name and any subsequent control characters.
  #
  # @see https://www.rubydoc.info/gems/yard/file/docs/Tags.md#types-specifier-list
  class Parser
    # Exception raised when encountering an invalid type string.
    class ParseError < StandardError; end

    def initialize
      @parser = TypesSpecifierListParser.new

      generate_node_map
    end

    # Parses a YARD type list.
    #
    # @return [Array<[SleepingKingStudios::Docs::Data::Types::Type]>] the parsed
    #   types.
    #
    # @raise [ParserError] if unable to parse the type.
    def parse(type)
      return [] if type.nil? || type.empty?

      result = parser.parse(type)

      raise ParseError, "unable to parse type `#{type}'" if result.nil?

      Array(handle_node(result))
    end

    private

    attr_reader :node_map

    attr_reader :parser

    def build_array(name:, values:, ordered: false)
      SleepingKingStudios::Docs::Data::Types::ParameterizedType.new(
        items:   values,
        name:,
        ordered:
      )
    end

    def build_basic(name:)
      SleepingKingStudios::Docs::Data::Types::Type.new(name:)
    end

    def build_hash(name:, keys:, values:)
      SleepingKingStudios::Docs::Data::Types::KeyValueType.new(
        keys:,
        name:,
        values:
      )
    end

    def generate_node_map # rubocop:disable Metrics/MethodLength
      @node_map =
        TypesSpecifierList
        .constants
        .select { |const_name| const_name.to_s.end_with?('0') }
        .sort
        .to_h \
      do |const_name|
        ext   = TypesSpecifierList.const_get(const_name)
        value = tools.string_tools.underscore(const_name.to_s[0...-1]).intern

        [ext, value]
      end
    end

    def handle_key_value_type(node)
      name   = node.elements.first.text_value
      keys   = Array(handle_node(node.elements[2]))
      values = Array(handle_node(node.elements[4]))

      build_hash(name:, keys:, values:)
    end

    def handle_identifier_with_whitespace(node)
      name = node.text_value.strip

      build_basic(name:)
    end

    def handle_node(node)
      node_type = identify_node_type(node)
      handler   = :"handle_#{node_type}"

      send(handler, node)
    end

    def handle_ordered_type(node)
      name   = node.elements.first.text_value
      values = Array(handle_node(node.elements[2]))

      build_array(name:, ordered: true, values:)
    end

    def handle_parameterized_type(node)
      name   = node.elements.first.text_value
      values = Array(handle_node(node.elements[2]))

      build_array(name:, values:)
    end

    def handle_type_list(node)
      if identify_node_type(node.elements.last) == :type_list
        return [
          handle_node(node.elements.first),
          *handle_type_list(node.elements.last)
        ]
      end

      [handle_node(node.elements.first), *handle_node(node.elements.last)]
    end

    def identify_node_type(node)
      return :text if node.extension_modules.empty?

      node_map
        .find { |type, _| node.extension_modules.include?(type) }
        &.last || :unknown_type
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
