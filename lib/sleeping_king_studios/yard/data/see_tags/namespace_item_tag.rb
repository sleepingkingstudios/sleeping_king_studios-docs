# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tags'

module SleepingKingStudios::Yard::Data::SeeTags
  # Data object representing a @see tag with a constant or method link.
  #
  # @abstract
  class NamespaceItemTag < SleepingKingStudios::Yard::Data::SeeTags::ReferenceTag # rubocop:disable Layout/LineLength
    # (see SleepingKingStudios::Yard::Data::SeeTags::Base#initialize)
    def initialize(native:, parent:)
      super

      split_reference
    end

    # @return [true, false] true if the constant is defined by the tagged
    #   object; otherwise false.
    def local?
      return @local unless @local.nil?

      @local = namespace == parent.name.to_s
    end

    # @return [String, nil] the path used to generate the reference link.
    def path
      return "##{type}-#{slugify(reference_name)}" if local?

      return "#{namespace_path}##{type}-#{slugify(reference_name)}" if exists?

      nil
    end

    # @return [String] the reference type.
    def type
      'reference'
    end

    private

    attr_reader \
      :namespace,
      :reference_name

    def namespace_path
      return '/' if namespace.empty?

      slugify_path(namespace)
    end

    def split_reference
      @namespace      = ''
      @reference_name = ''
    end
  end
end
