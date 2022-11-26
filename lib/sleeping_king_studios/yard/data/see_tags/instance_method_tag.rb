# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tags'

module SleepingKingStudios::Yard::Data::SeeTags
  # Data object representing a @see tag with an instance method link.
  class InstanceMethodTag < SleepingKingStudios::Yard::Data::SeeTags::NamespaceItemTag # rubocop:disable Layout/LineLength
    DEFINITION_PREFIX =
      '(::)?[[:upper:]][[:alnum:]]*(::[[:upper:]][[:alnum:]]*)*'
    private_constant :DEFINITION_PREFIX

    INSTANCE_METHOD_PATTERN =
      /\A(#{DEFINITION_PREFIX})?#([[[:lower:]][[:digit:]]_])+[=?]?\z/
      .freeze
    private_constant :INSTANCE_METHOD_PATTERN

    class << self
      # Checks if the given tag object is a reference to an instance method.
      #
      # @param native [YARD::Tags::Tag] the tag object.
      #
      # @return [true, false] true if the tag object is a reference; otherwise
      #   false.
      def match?(native)
        native.name.sub(/\.\z/, '').match?(INSTANCE_METHOD_PATTERN)
      end
      alias matches? match?
    end

    # @return [true, false] true if the referenced class method is an attribute;
    #   otherwise false.
    def attribute?
      return @attribute unless @attribute.nil?

      return @attribute = false unless exists?

      method_path = absolute_path? ? reference : relative_path

      native_method = registry.find do |obj|
        obj.type == :method &&
          obj.scope == :instance &&
          obj.path == method_path
      end

      @attribute = native_method.is_attribute?
    end

    # @return [String] the reference type.
    def type
      attribute? ? 'instance-attribute' : 'instance-method'
    end

    private

    def absolute_path?
      return @absolute_path unless @absolute_path.nil?

      @absolute_path = registry_query.instance_method_exists?(reference)
    end

    def relative_path
      if reference.start_with?('#') || reference.start_with?('::')
        return "#{parent.name}#{reference}"
      end

      "#{parent.name}::#{reference}"
    end

    def relative_path?
      return @relative_path unless @relative_path.nil?

      return @relative_path = false if parent.root?

      @relative_path = registry_query.instance_method_exists?(relative_path)
    end

    def split_reference
      scoped          = relative_path? ? relative_path : reference
      segments        = scoped.split('#')
      @reference_name = segments.pop
      @namespace      = segments.last
    end
  end
end
