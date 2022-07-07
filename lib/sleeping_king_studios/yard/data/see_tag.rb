# frozen_string_literal: true

require 'sleeping_king_studios/yard/data'

module SleepingKingStudios::Yard::Data
  # Object representing a YARD @see tag.
  #
  # Each @see tag has a referenced object or link, and may additionally have
  # freeform text used for display purposes. A referenced object may have a
  # corresponding object in the YARD registry, in which case it should be
  # displayed as an internal link.
  class SeeTag # rubocop:disable Metrics/ClassLength
    # Pattern used to identify a class method.
    CLASS_METHOD_PATTERN = /(\.|::)[a-z_][a-z0-9_]*\z/.freeze

    # Pattern used to identify a constant.
    CONSTANT_PATTERN = /(\A|::)[A-Z][A-Z_]*\z/.freeze

    # Pattern used to identify an instance method.
    INSTANCE_METHOD_PATTERN = /#[a-z_][a-z0-9_]*\z/.freeze

    # Pattern used to match external links. YARD seems to use the presence of a
    # protocol to identify a link, so "http://foo" is a valid link, but
    # "www.example.com" is not.
    LINK_PATTERN = %r{\A\w+://\w+}.freeze

    # Separator used to join the scope to the referenced code object.
    SEPARATORS = {
      class_method:    '.',
      constant:        '::',
      instance_method: '#'
    }.freeze

    UNDEFINED = Object.new.freeze
    private_constant :UNDEFINED

    # @param native [YARD::Tags::Tag] the YARD object representing the @see tag.
    # @param registry [Module] the YARD registry.
    def initialize(native:, registry:)
      @native         = native
      @registry       = registry
      @reference_type = UNDEFINED
    end

    # Generates a JSON-compatible representation of the namespace.
    #
    # Returns a Hash with the following keys:
    #
    # - 'text': The text to display for the tag.
    #
    # A @see tag with an external link will include the following key:
    #
    # - 'link': The url of the link to display.
    #
    # A @see tag with a valid code reference will also include the following
    # keys:
    #
    # - 'path': The internal path of the referenced definition or namespace.
    # - 'type': One of 'definition', 'constant', 'class_method', or
    #   'instance_method'.
    # - (optional) 'constant': The name of the referenced constant, if any, in a
    #   url-safe, hyphen-separated format.
    # - (optional) 'method': The name of the referenced constant, if any, in a
    #   url-safe, hyphen-separated format.
    #
    # @return [Hash{String, String}] the representation of the tag.
    def as_json
      return format_link      if link?
      return format_reference if reference? && reference_type

      { 'text' => text }
    end

    # @return [Boolean] true if the tag is an external link, otherwise false.
    def link?
      @is_link ||= reference.match?(LINK_PATTERN) # rubocop:disable Naming/MemoizedInstanceVariableName
    end

    # @return [Boolean] true if the tag is a plain text tag, otherwise false.
    def plain_text?
      reference == '_'
    end

    # The name of the referenced object or link.
    #
    # As a special case, a referenced name of "_" is used by convention to
    # indicate a plain text reference.
    #
    # @return [String] the name of the referenced object or link.
    def reference
      @reference ||= strip_trailing_period(native.name)
    end

    # @return [Boolean] true if the tag is an object reference, otherwise false.
    def reference?
      !(plain_text? || link?)
    end

    # @return [Symbol, nil] the type of referenced object, one of :definition,
    #   :constant, :class_method, or :instance_method.
    def reference_type
      return @reference_type unless @reference_type == UNDEFINED

      match_reference

      @reference_type
    end

    # The text to display when rendering the tag.
    #
    # @return [String] the text to display.
    def text
      @text ||= (text? ? native.text : reference)
    end

    # @return [Boolean] true if the tag has display text, otherwise false.
    def text?
      !native.text.nil?
    end

    private

    attr_reader :native

    attr_reader :registry

    def class_method?
      reference.match?(CLASS_METHOD_PATTERN)
    end

    def class_method_exists?(ref_name = nil)
      ref_name ||= reference

      # Handle top-level class methods.
      return top_level_class_method_exists? if ref_name.start_with?('.')

      # Handle legacy ::class_method format.
      return legacy_class_method_exists? unless ref_name.include?('.')

      registry.any? do |obj|
        obj.type == :method && obj.scope == :class && obj.title == ref_name
      end
    end

    def constant?
      reference.match?(CONSTANT_PATTERN)
    end

    def constant_exists?
      registry.any? { |obj| obj.type == :constant && obj.title == reference }
    end

    def definition_exists?
      registry.any? do |obj|
        (obj.type == :module || obj.type == :class) && obj.title == reference
      end
    end

    def find_reference_type # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      if class_method?
        class_method_exists? ? :class_method : nil
      elsif constant?
        constant_exists? ? :constant : nil
      elsif instance_method?
        instance_method_exists? ? :instance_method : nil
      elsif definition_exists?
        :definition
      end
    end

    def format_definition
      {
        'path' => slugify(reference),
        'text' => text,
        'type' => 'definition'
      }
    end

    def format_link
      {
        'link' => reference,
        'text' => text
      }
    end

    def format_reference
      return format_definition if reference_type == :definition

      type = reference_type.to_s

      {
        type   => slugify(reference_value),
        'path' => slugify(reference_scope),
        'text' => text,
        'type' => type
      }
    end

    def instance_method?
      reference.match?(INSTANCE_METHOD_PATTERN)
    end

    def instance_method_exists?
      registry.any? do |obj|
        obj.type == :method && obj.scope == :instance && obj.title == reference
      end
    end

    def legacy_class_method_exists?
      ref_name ||= reference.reverse.sub('::', '.').reverse

      registry.any? do |obj|
        obj.type == :method && obj.scope == :class && obj.title == ref_name
      end
    end

    def match_reference
      unless reference?
        @reference_type = nil

        return
      end

      @reference_type = find_reference_type
    end

    def reference_scope
      return @reference_scope if @reference_scope

      offset = reference_value.size + separator.size

      reference[0...-offset]
    end

    def reference_value
      @reference_value ||= reference.split(separator).last
    end

    def separator
      SEPARATORS[reference_type]
    end

    def slugify(str)
      tools.string_tools.underscore(str).tr('_', '-').tr(':', '-')
    end

    def strip_trailing_period(str)
      return str unless str.end_with?('.')

      str[0...-1]
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def top_level_class_method_exists?
      ref_name ||= "::#{reference[1..]}"

      registry.any? do |obj|
        obj.type == :method && obj.scope == :class && obj.title == ref_name
      end
    end
  end
end
