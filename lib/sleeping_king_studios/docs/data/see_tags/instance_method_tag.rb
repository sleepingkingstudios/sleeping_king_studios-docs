# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/see_tags'

module SleepingKingStudios::Docs::Data::SeeTags
  # Data object representing a @see tag with an instance method link.
  class InstanceMethodTag < SleepingKingStudios::Docs::Data::SeeTags::NamespaceItemTag # rubocop:disable Layout/LineLength
    DEFINITION_PREFIX =
      '(::)?[[:upper:]][[:alnum:]]*(::[[:upper:]][[:alnum:]]*)*'
    private_constant :DEFINITION_PREFIX

    INSTANCE_METHOD_PATTERN =
      /\A(#{DEFINITION_PREFIX})?#([[[:lower:]][[:digit:]]_])+[=?]?\z/

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

      method_path = absolute_path? ? reference : qualified_path

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

    def query_registry(name)
      registry_query.instance_method_exists?(name)
    end

    def split_reference
      scoped          = relative_path? ? qualified_path : reference
      segments        = scoped.split('#')
      @reference_name = segments.pop
      @namespace      = segments.last
    end
  end
end
