# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tags'

module SleepingKingStudios::Yard::Data::SeeTags
  # Data object representing a @see tag with a constant link.
  class ConstantTag < SleepingKingStudios::Yard::Data::SeeTags::NamespaceItemTag
    DEFINITION_PREFIX =
      '(::)?[[:upper:]][[:alnum:]]*(::[[:upper:]][[:alnum:]]*)*'
    private_constant :DEFINITION_PREFIX

    CONSTANT_PATTERN =
      /\A((#{DEFINITION_PREFIX})?::)?[[:upper:]]([[[:upper:]][[:digit:]]_])*\z/
      .freeze
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

    def absolute_path?
      return @absolute_path unless @absolute_path.nil?

      @absolute_path = registry_query.constant_exists?(reference)
    end

    def relative_path
      "#{parent.name}::#{reference}"
    end

    def relative_path?
      return @relative_path unless @relative_path.nil?

      return @relative_path = false if parent.root?

      return @relative_path = false if native.name.start_with?('::')

      @relative_path = registry_query.constant_exists?(relative_path)
    end

    def split_reference
      scoped          = relative_path? ? relative_path : reference
      segments        = scoped.split('::')
      @reference_name = segments.pop
      @namespace      = segments.join('::')
    end
  end
end
