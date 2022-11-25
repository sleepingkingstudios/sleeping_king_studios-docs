# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tags'

module SleepingKingStudios::Yard::Data::SeeTags
  # Data object representing a @see tag with a reference link.
  class ReferenceTag < SleepingKingStudios::Yard::Data::SeeTags::Base
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
      false
    end

    def registry_query
      @registry_query ||=
        SleepingKingStudios::Yard::RegistryQuery.new(registry: registry)
    end

    def relative_path?
      false
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
