# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tags'

module SleepingKingStudios::Yard::Data::SeeTags
  # Data object representing a @see tag with a reference link.
  #
  # @abstract
  class ReferenceTag < SleepingKingStudios::Yard::Data::SeeTags::Base
    SEPARATORS = ['::', '.', '#'].freeze
    private_constant :SEPARATORS

    # Generates a JSON-compatible representation of the tag.
    #
    # Returns a Hash with the following keys:
    #
    # - 'label': The label used to generate the reference link.
    # - 'path': The path used to generate the reference link.
    # - 'text': The text to display for the tag.
    # - 'type': The string 'reference'.
    def as_json
      {
        'label' => label,
        'path'  => path,
        'text'  => text,
        'type'  => 'reference'
      }
    end

    # Checks if the referenced code object exists in the registry.
    #
    # @return [true, false] true if the referenced code object exists; otherwise
    #   false.
    def exists?
      relative_path? || absolute_path?
    end

    # @return [String, nil] the path used to generate the reference link.
    def path
      nil
    end

    # @return [String] the label used to generate the reference link.
    def reference
      @reference ||= native.name.sub(/\.\z/, '')
    end
    alias label reference

    private

    def absolute_path?
      return @absolute_path unless @absolute_path.nil?

      @absolute_path = query_registry(reference)
    end

    def query_registry(_)
      false
    end

    def registry_query
      @registry_query ||=
        SleepingKingStudios::Yard::RegistryQuery.new(registry:)
    end

    def qualified_path
      return @qualified_path if @qualified_path

      if SEPARATORS.any? { |sep| reference.start_with?(sep) }
        return @qualified_path = "#{parent.path}#{reference}"
      end

      @qualified_path = "#{parent.path}::#{reference}"
    end

    def relative_path?
      return @relative_path unless @relative_path.nil?

      return @relative_path = false if parent.root?

      @relative_path = query_registry(qualified_path)
    end

    def slugify_path(path)
      path
        .sub(/\A::/, '')
        .split('::')
        .map { |str| slugify(str) }
        .join('/')
    end
  end
end
