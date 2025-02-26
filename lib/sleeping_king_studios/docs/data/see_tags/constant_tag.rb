# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/see_tags'

module SleepingKingStudios::Docs::Data::SeeTags
  # Data object representing a @see tag with a constant link.
  class ConstantTag < SleepingKingStudios::Docs::Data::SeeTags::NamespaceItemTag
    DEFINITION_PREFIX =
      '(::)?[[:upper:]][[:alnum:]]*(::[[:upper:]][[:alnum:]]*)*'
    private_constant :DEFINITION_PREFIX

    CONSTANT_PATTERN =
      /\A((#{DEFINITION_PREFIX})?::)?[[:upper:]]([[[:upper:]][[:digit:]]_])*\z/

    private_constant :CONSTANT_PATTERN

    class << self
      # Checks if the given tag object is a reference to a constant.
      #
      # @param native [YARD::Tags::Tag] the tag object.
      #
      # @return [true, false] true if the tag object is a reference; otherwise
      #   false.
      def match?(native)
        native.name.sub(/\.\z/, '').match?(CONSTANT_PATTERN)
      end
      alias matches? match?
    end

    # @return [String] the label used to generate the reference link.
    def reference
      @reference ||= super.sub(/\A::/, '')
    end
    alias label reference

    # @return [String] the reference type.
    def type
      'constant'
    end

    private

    def query_registry(name)
      registry_query.constant_exists?(name)
    end

    def relative_path?
      return @relative_path = false if native.name.start_with?('::')

      super
    end

    def split_reference
      scoped          = relative_path? ? qualified_path : reference
      segments        = scoped.split('::')
      @reference_name = segments.pop
      @namespace      = segments.join('::')
    end
  end
end
