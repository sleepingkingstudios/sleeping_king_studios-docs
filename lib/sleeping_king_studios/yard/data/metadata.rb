# frozen_string_literal: true

require 'set'

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
  # @see SleepingKingStudios::Yard::Data::SeeTags.
  class Metadata < SleepingKingStudios::Yard::Data::Base
    EMPTYABLE_PROPERTIES = Set.new(
      %i[
        abstract
        deprecated
      ]
    ).freeze
    private_constant :EMPTYABLE_PROPERTIES

    METADATA_PROPERTIES = %i[
      abstract
      api
      authors
      deprecated
      examples
      notes
      see
      since
      todos
      versions
    ].freeze
    private_constant :METADATA_PROPERTIES

    # Returns the @abstract tag, if any, defined for the module.
    #
    # @return [String] the contents of the @abstract tag, or an empty string if
    #   the tag does not have contents.
    # @return [nil] if there is no @abstract tag defined.
    def abstract
      @abstract ||=
        native
        .tags
        .find { |tag| tag.tag_name == 'abstract' }
        &.text
    end

    # Returns the @api tag, if any, defined for the module.
    #
    # @return [String] the contents of the @api tag.
    # @return [nil] if there is no @api tag defined.
    def api
      @api ||=
        native
        .tags
        .find { |tag| tag.tag_name == 'api' }
        &.text
    end

    # Generates a JSON-compatible representation of the metadata.
    #
    # Returns a Hash with zero or more of the following keys:
    #
    # - 'examples': An Array of Hashes with keys 'name' and 'text' and String
    #   values.
    # - 'notes': An Array of Strings.
    # - 'see': An Array of Hashes with String values.
    # - 'todo': An Array of Strings.
    #
    # @return [Hash{String => Object}] the representation of the metadata.
    def as_json
      METADATA_PROPERTIES
        .reduce({}) do |memo, property_name|
          value = send(property_name)

          next memo if emptyable?(property_name) ? value.nil? : empty?(value)

          memo.update(property_name.to_s => value)
        end
    end

    # Collects the @author tags defined for the module.
    #
    # @return [Array<String>] the collected authors.
    def authors
      @authors ||=
        select_tags('author') { |tag| !tag.text.empty? }
        .map(&:text)
    end

    # Returns the @deprecated tag, if any, defined for the module.
    #
    # @return [String] the contents of the @deprecated tag, or an empty string
    #   if the tag does not have contents.
    # @return [nil] if there is no @deprecated tag defined.
    def deprecated
      @deprecated ||=
        native
        .tags
        .find { |tag| tag.tag_name == 'deprecated' }
        &.text
    end

    # Collects the @example tags defined for the module.
    #
    # Each @example tag is represented as a Hash with the following keys:
    #
    # - 'name': The displayed name of the example. May be an empty String.
    # - 'text': The text for the example.
    #
    # @return [Array<Hash{String => String}>] the collected examples.
    def examples
      @examples ||=
        select_tags('example')
        .map { |tag| { 'name' => tag.name, 'text' => tag.text } }
    end

    # Collects the @note tags defined for the module.
    #
    # @return [Array<String>] the collected notes.
    def notes
      @notes ||= select_tags('note').map(&:text)
    end

    # Collects the @see tags defined the for the module.
    #
    # Each @see tag is represented as a Hash with String keys and values, and
    # has at a minimum the 'text' key. See the SeeTag#as_json method for
    # details.
    #
    # @return [Array<Hash{String => String}>]
    def see
      @see ||= select_tags('see').map { |tag| format_see_tag(tag) }
    end

    # Collects the @since tags defined for the module.
    #
    # @return [Array<String>] the collected @since tags.
    def since
      @since ||=
        select_tags('since') { |tag| !tag.text.empty? }
        .map(&:text)
    end

    # Collects the @todo tags defined for the module.
    #
    # @return [Array<String>] the collected todos.
    def todos
      @todos ||= select_tags('todo').map(&:text)
    end

    # Collects the @version tags defined for the module.
    #
    # @return [Array<String>] the collected @version tags.
    def versions
      @versions ||=
        select_tags('version') { |tag| !tag.text.empty? }
        .map(&:text)
    end

    private

    def definition_tag?(tag)
      tag.type == :class || tag.type == :module # rubocop:disable Style/MultipleComparison
    end

    def emptyable?(property_name)
      EMPTYABLE_PROPERTIES.include?(property_name)
    end

    def format_see_tag(tag)
      SleepingKingStudios::Yard::Data::SeeTags
        .build(
          native: tag,
          parent: definition_tag?(native) ? native : native.parent
        )
        .as_json
    end

    def select_tags(tag_name)
      native.tags.select do |tag|
        (tag.tag_name == tag_name) &&
          (!block_given? || yield(tag))
      end
    end
  end
end
