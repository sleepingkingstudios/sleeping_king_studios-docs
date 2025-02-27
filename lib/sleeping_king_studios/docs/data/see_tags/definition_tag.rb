# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/see_tags'

module SleepingKingStudios::Docs::Data::SeeTags
  # Data object representing a @see tag with a definition link.
  class DefinitionTag < SleepingKingStudios::Docs::Data::SeeTags::ReferenceTag
    DEFINITION_PATTERN =
      /\A(::)?[[:upper:]][[:alnum:]]*(::[[:upper:]][[:alnum:]]*)*\z/
    private_constant :DEFINITION_PATTERN

    class << self
      # Checks if the given tag object is a reference to a class or module.
      #
      # @param native [YARD::Tags::Tag] the tag object.
      #
      # @return [true, false] true if the tag object is a reference; otherwise
      #   false.
      def match?(native)
        native.name.sub(/\.\z/, '').match?(DEFINITION_PATTERN)
      end
      alias matches? match?
    end

    # @return [String, nil] the path used to generate the reference link.
    def path
      return slugify_path(qualified_path) if relative_path?

      return slugify_path(reference) if absolute_path?

      nil
    end

    # @return [String] the label used to generate the reference link.
    def reference
      @reference ||= super.sub(/\A::/, '')
    end
    alias label reference

    private

    def query_registry(name)
      registry_query.definition_exists?(name)
    end

    def relative_path?
      return false if native.name.start_with?('::')

      super
    end
  end
end
