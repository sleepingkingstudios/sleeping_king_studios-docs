# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tags'

module SleepingKingStudios::Yard::Data::SeeTags
  # Data object representing a @see tag with a class method link.
  class ClassMethodTag < SleepingKingStudios::Yard::Data::SeeTags::NamespaceItemTag # rubocop:disable Layout/LineLength
    DEFINITION_PREFIX =
      '(::)?[[:upper:]][[:alnum:]]*(::[[:upper:]][[:alnum:]]*)*'
    private_constant :DEFINITION_PREFIX

    CLASS_METHOD_PATTERN =
      /\A(#{DEFINITION_PREFIX})?\.([[[:lower:]][[:digit:]]_])+[=?]?\z/
      .freeze
    private_constant :CLASS_METHOD_PATTERN

    LEGACY_CLASS_METHOD_PATTERN =
      /\A(#{DEFINITION_PREFIX})?::([[[:lower:]][[:digit:]]_])+\z/
      .freeze
    private_constant :LEGACY_CLASS_METHOD_PATTERN

    class << self
      # Checks if the given tag object is a reference to a class method.
      #
      # @param native [YARD::Tags::Tag] the tag object.
      #
      # @return [true, false] true if the tag object is a reference; otherwise
      #   false.
      def match?(native)
        name = native.name.sub(/\.\z/, '')

        name.match?(CLASS_METHOD_PATTERN) ||
          name.match?(LEGACY_CLASS_METHOD_PATTERN)
      end
      alias matches? match?
    end

    # @return [true, false] true if the referenced class method is an attribute;
    #   otherwise false.
    def attribute? # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      return @attribute unless @attribute.nil?

      return @attribute = false unless exists?

      method_path = absolute_path? ? reference : relative_path

      unless method_path.include?('.')
        method_path = method_path.reverse.sub('::', '.').reverse
      end

      native_method = registry.find do |obj|
        obj.type == :method &&
          obj.scope == :class &&
          obj.path == method_path
      end

      @attribute = native_method.is_attribute?
    end

    # @return [String] the reference type.
    def type
      attribute? ? 'class-attribute' : 'class-method'
    end

    private

    def absolute_path?
      return @absolute_path unless @absolute_path.nil?

      @absolute_path = registry_query.class_method_exists?(reference)
    end

    def namespace_path
      return '/' if namespace.empty?

      slugify_path(namespace)
    end

    def relative_path
      if reference.start_with?('.') || reference.start_with?('::')
        return "#{parent.name}#{reference}"
      end

      "#{parent.name}::#{reference}"
    end

    def relative_path?
      return @relative_path unless @relative_path.nil?

      return @relative_path = false if parent.root?

      @relative_path = registry_query.class_method_exists?(relative_path)
    end

    def split_legacy_reference
      scoped          = relative_path? ? relative_path : reference
      segments        = scoped.split('::')
      @reference_name = segments.pop
      @namespace      = segments.join('::')
    end

    def split_method_reference
      scoped          = relative_path? ? relative_path : reference
      segments        = scoped.split('.')
      @reference_name = segments.pop
      @namespace      = segments.last
    end

    def split_reference
      if reference.include?('.')
        split_method_reference
      else
        split_legacy_reference
      end
    end
  end
end
