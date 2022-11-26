# frozen_string_literal: true

require 'sleeping_king_studios/yard/data'

module SleepingKingStudios::Yard::Data
  # Namespace for objects representing YARD @see tags.
  module SeeTags
    autoload :Base,
      'sleeping_king_studios/yard/data/see_tags/base'
    autoload :ClassMethodTag,
      'sleeping_king_studios/yard/data/see_tags/class_method_tag'
    autoload :ConstantTag,
      'sleeping_king_studios/yard/data/see_tags/constant_tag'
    autoload :DefinitionTag,
      'sleeping_king_studios/yard/data/see_tags/definition_tag'
    autoload :InstanceMethodTag,
      'sleeping_king_studios/yard/data/see_tags/instance_method_tag'
    autoload :LinkTag,
      'sleeping_king_studios/yard/data/see_tags/link_tag'
    autoload :NamespaceItemTag,
      'sleeping_king_studios/yard/data/see_tags/namespace_item_tag'
    autoload :ReferenceTag,
      'sleeping_king_studios/yard/data/see_tags/reference_tag'
    autoload :TextTag,
      'sleeping_king_studios/yard/data/see_tags/text_tag'

    class << self
      # Creates a wrapper object for the given @see tag.
      #
      # @param native [YARD::Tags::Tag] the YARD object representing the @see
      #   tag.
      # @param parent [YARD::Tags::Tag] the YARD object representing the parent
      #   object, which contains the @see tag.
      #
      # @return [SleepingKingStudios::Yard::Data::SeeTags::Base] the wrapped
      #   object representing the @see tag.
      def build(native:, parent:)
        build_text_tag(native: native, parent: parent) ||
          build_link_tag(native: native, parent: parent) ||
          build_constant_tag(native: native, parent: parent) ||
          build_class_method_tag(native: native, parent: parent) ||
          build_definition_tag(native: native, parent: parent) ||
          build_instance_method_tag(native: native, parent: parent)
      end

      private

      def build_class_method_tag(native:, parent:)
        return unless ClassMethodTag.match?(native)

        ClassMethodTag.new(native: native, parent: parent)
      end

      def build_constant_tag(native:, parent:)
        return unless ConstantTag.match?(native)

        # Special check for ambiguous definitions, e.g. HTTP, NASA.
        constant_tag = ConstantTag.new(native: native, parent: parent)

        return constant_tag if constant_tag.exists?

        definition_tag = DefinitionTag.new(native: native, parent: parent)

        # If neither the constant nor the definition exists, and the format
        # matches a constant, assume it is a constant.
        definition_tag.exists? ? definition_tag : constant_tag
      end

      def build_definition_tag(native:, parent:)
        return unless DefinitionTag.match?(native)

        DefinitionTag.new(native: native, parent: parent)
      end

      def build_link_tag(native:, parent:)
        return unless LinkTag.match?(native)

        LinkTag.new(native: native, parent: parent)
      end

      def build_instance_method_tag(native:, parent:)
        return unless InstanceMethodTag.match?(native)

        InstanceMethodTag.new(native: native, parent: parent)
      end

      def build_text_tag(native:, parent:)
        return unless TextTag.match?(native)

        TextTag.new(native: native, parent: parent)
      end
    end
  end
end
