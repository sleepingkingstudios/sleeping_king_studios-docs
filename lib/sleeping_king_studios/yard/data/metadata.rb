# frozen_string_literal: true

require 'sleeping_king_studios/yard/data'

module SleepingKingStudios::Yard::Data
  # Object representing the metadata tags for a Ruby module.
  #
  # Each module can have the following metadata tags:
  #
  # - @example
  # - @note
  # - @see
  # - @todo
  #
  # Other tags are not currently supported.
  #
  # @see SleepingKingStudios::Yard::Data::ModuleObject.
  # @see SleepingKingStudios::Yard::Data::SeeTag.
  class Metadata < SleepingKingStudios::Yard::Data::Base
    METADATA_PROPERTIES = %i[
      examples
      notes
      see
      todos
    ].freeze
    private_constant :METADATA_PROPERTIES

    # Generates a JSON-compatible representation of the metadata.
    #
    # Returns a Hash with zero or more of the following keys:
    #
    # - 'examples': An Array of Hashes with keys 'name' and 'text' and String
    #   values.
    # - 'notes': An Array of Strings.
    # - 'see': An Array of Hashes with String values. See the SeeTag#as_json
    #   method for details.
    # - 'todo': An Array of Strings.
    #
    # @return [Hash{String, Object}] the representation of the metadata.
    #
    # @see SleepingKingStudios::Yard::Data::SeeTag#as_json.
    def as_json
      METADATA_PROPERTIES.reduce({}) do |memo, property_name|
        value = send(property_name)

        next memo if empty?(value)

        memo.update(property_name.to_s => value)
      end
    end

    # Collects the @example tags defined for the module.
    #
    # Each @example tag is represented as a Hash with the following keys:
    #
    # - 'name': The displayed name of the example. May be an empty String.
    # - 'text': The text for the example.
    #
    # @return [Array<Hash{String, String}>] the collected examples.
    def examples
      @examples ||=
        native
        .tags
        .select { |tag| tag.tag_name == 'example' }
        .map { |tag| { 'name' => tag.name, 'text' => tag.text } }
    end

    # Collects the @note tags defined for the module.
    #
    # @return [Array<String>] the collected notes.
    def notes
      @notes ||=
        native
        .tags
        .select { |tag| tag.tag_name == 'note' }
        .map(&:text)
    end

    # Collects the @see tags defined the for the module.
    #
    # Each @see tag is represented as a Hash with String keys and values, and
    # has at a minimum the 'text' key. See the SeeTag#as_json method for
    # details.
    #
    # @return [Array<Hash{String, String}>]
    #
    # @see SleepingKingStudios::Yard::Data::SeeTag#as_json.
    def see
      @see ||=
        native
        .tags
        .select { |tag| tag.tag_name == 'see' }
        .map { |tag| format_see_tag(tag) }
    end

    # Collects the @todo tags defined for the module.
    #
    # @return [Array<String>] the collected notes.
    def todos
      @todos ||=
        native
        .tags
        .select { |tag| tag.tag_name == 'todo' }
        .map(&:text)
    end

    private

    def format_see_tag(tag)
      SleepingKingStudios::Yard::Data::SeeTag
        .new(native: tag)
        .as_json
    end
  end
end
