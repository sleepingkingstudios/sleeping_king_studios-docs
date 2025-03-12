# frozen_string_literal: true

require 'sleeping_king_studios/docs/data'

module SleepingKingStudios::Docs::Data
  # Namespace for objects representing YARD @see tags.
  module SeeTags
    autoload :Base,
      'sleeping_king_studios/docs/data/see_tags/base'
    autoload :ClassMethodTag,
      'sleeping_king_studios/docs/data/see_tags/class_method_tag'
    autoload :ConstantTag,
      'sleeping_king_studios/docs/data/see_tags/constant_tag'
    autoload :DefinitionTag,
      'sleeping_king_studios/docs/data/see_tags/definition_tag'
    autoload :InstanceMethodTag,
      'sleeping_king_studios/docs/data/see_tags/instance_method_tag'
    autoload :LinkTag,
      'sleeping_king_studios/docs/data/see_tags/link_tag'
    autoload :NamespaceItemTag,
      'sleeping_king_studios/docs/data/see_tags/namespace_item_tag'
    autoload :ReferenceTag,
      'sleeping_king_studios/docs/data/see_tags/reference_tag'
    autoload :TextTag,
      'sleeping_king_studios/docs/data/see_tags/text_tag'
    autoload :UnstructuredTag,
      'sleeping_king_studios/docs/data/see_tags/unstructured_tag'

    class << self
      # Creates a wrapper object for the given @see tag.
      #
      # @param native [YARD::Tags::Tag] the YARD object representing the @see
      #   tag.
      # @param parent [YARD::Tags::Tag] the YARD object representing the parent
      #   object, which contains the @see tag.
      #
      # @return [SleepingKingStudios::Docs::Data::SeeTags::Base] the wrapped
      #   object representing the @see tag.
      def build(native:, parent:)
        build_text_tag(native:, parent:) ||
          build_link_tag(native:, parent:) ||
          build_constant_tag(native:, parent:) ||
          build_class_method_tag(native:, parent:) ||
          build_definition_tag(native:, parent:) ||
          build_instance_method_tag(native:, parent:) ||
          build_unstructured_tag(native:, parent:)
      end

      private

      def build_class_method_tag(native:, parent:)
        return unless ClassMethodTag.match?(native)

        ClassMethodTag.new(native:, parent:)
      end

      def build_constant_tag(native:, parent:)
        return unless ConstantTag.match?(native)

        # Special check for ambiguous definitions, e.g. HTTP, NASA.
        constant_tag = ConstantTag.new(native:, parent:)

        return constant_tag if constant_tag.exists?

        definition_tag = DefinitionTag.new(native:, parent:)

        # If neither the constant nor the definition exists, and the format
        # matches a constant, assume it is a constant.
        definition_tag.exists? ? definition_tag : constant_tag
      end

      def build_definition_tag(native:, parent:)
        return unless DefinitionTag.match?(native)

        DefinitionTag.new(native:, parent:)
      end

      def build_link_tag(native:, parent:)
        return unless LinkTag.match?(native)

        LinkTag.new(native:, parent:)
      end

      def build_instance_method_tag(native:, parent:)
        return unless InstanceMethodTag.match?(native)

        InstanceMethodTag.new(native:, parent:)
      end

      def build_text_tag(native:, parent:)
        return unless TextTag.match?(native)

        TextTag.new(native:, parent:)
      end

      def build_unstructured_tag(native:, parent:)
        UnstructuredTag.new(native:, parent:)
      end
    end
  end
end
