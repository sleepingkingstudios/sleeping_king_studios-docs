# frozen_string_literal: true

require 'sleeping_king_studios/yard/data'

module SleepingKingStudios::Yard::Data
  # Object representing a YARD @see tag.
  #
  # Each @see tag has a referenced object or link, and may additionally have
  # freeform text used for display purposes. A referenced object may have a
  # corresponding object in the YARD registry, in which case it should be
  # displayed as an internal link.
  #
  # @see SleepingKingStudios::Yard::Data::Metadata.
  class SeeTag < SleepingKingStudios::Yard::Data::Base # rubocop:disable Metrics/ClassLength
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
    def initialize(native:)
      super

      @reference_type = UNDEFINED

      split_reference
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
    # @return [Hash{String => String}] the representation of the tag.
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

    attr_reader \
      :reference_definition,
      :reference_value

    def class_method?
      reference.match?(CLASS_METHOD_PATTERN)
    end

    def class_method_type
      registry_query.class_method_exists?(reference) ? :class_method : nil
    end

    def constant?
      reference.match?(CONSTANT_PATTERN)
    end

    def constant_type
      registry_query.constant_exists?(reference) ? :constant : nil
    end

    def definition_type
      registry_query.definition_exists?(reference) ? :definition : nil
    end

    def find_reference_type
      return class_method_type    if class_method?
      return constant_type        if constant?
      return instance_method_type if instance_method?

      definition_type
    end

    def format_class_method
      {
        'label' => reference,
        'path'  => reference_path,
        'text'  => native.text,
        'type'  => 'reference'
      }
    end

    def format_constant
      {
        'label' => reference,
        'path'  => reference_path,
        'text'  => native.text,
        'type'  => 'reference'
      }
    end

    def format_definition
      {
        'label' => reference,
        'path'  => slugify(reference),
        'text'  => native.text,
        'type'  => 'reference'
      }
    end

    def format_instance_method
      {
        'label' => reference,
        'path'  => reference_path,
        'text'  => native.text,
        'type'  => 'reference'
      }
    end

    def format_link
      {
        'label' => reference,
        'path'  => reference,
        'text'  => native.text,
        'type'  => 'link'
      }
    end

    def format_reference
      case reference_type
      when :class_method
        format_class_method
      when :constant
        format_constant
      when :definition
        format_definition
      when :instance_method
        format_instance_method
      end
    end

    def instance_method?
      reference.match?(INSTANCE_METHOD_PATTERN)
    end

    def instance_method_type
      registry_query.instance_method_exists?(reference) ? :instance_method : nil
    end

    def match_reference
      unless reference?
        @reference_type = nil

        return
      end

      @reference_type = find_reference_type
    end

    def reference_path
      "#{slugify(reference_definition)}#" \
        "#{slugify(reference_type)}-#{slugify(reference_value)}"
    end

    def registry_query
      @registry_query ||=
        SleepingKingStudios::Yard::RegistryQuery.new(registry: registry)
    end

    def separator
      SEPARATORS[reference_type]
    end

    def slugify(str)
      return super unless str.to_s.include?(':')

      str.split('::').map { |segment| super(segment) }.join('/')
    end

    def split_reference
      segments = reference.split(separator)

      @reference_value      = segments.pop
      @reference_definition = segments.join('::')
    end

    def strip_trailing_period(str)
      return str unless str.end_with?('.')

      str[0...-1]
    end
  end
end
