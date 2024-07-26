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

    private_constant :CLASS_METHOD_PATTERN

    LEGACY_CLASS_METHOD_PATTERN =
      /\A(#{DEFINITION_PREFIX})?::([[[:lower:]][[:digit:]]_])+\z/

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
    def attribute?
      return @attribute unless @attribute.nil?

      return @attribute = false unless exists?

      native_method = registry.find do |obj|
        obj.type == :method &&
          obj.scope == :class &&
          obj.path == normalized_path
      end

      @attribute = native_method.is_attribute?
    end

    # @return [String] the reference type.
    def type
      attribute? ? 'class-attribute' : 'class-method'
    end

    private

    def normalized_path
      return @normalized_path if @normalized_path

      @normalized_path = absolute_path? ? reference : qualified_path

      return @normalized_path if @normalized_path.include?('.')

      @normalized_path = @normalized_path.reverse.sub('::', '.').reverse
    end

    def query_registry(name)
      registry_query.class_method_exists?(name)
    end

    def split_legacy_reference
      scoped          = relative_path? ? qualified_path : reference
      segments        = scoped.split('::')
      @reference_name = segments.pop
      @namespace      = segments.join('::')
    end

    def split_method_reference
      scoped          = relative_path? ? qualified_path : reference
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
