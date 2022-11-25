# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tags'

module SleepingKingStudios::Yard::Data::SeeTags
  # Data object representing a plain text @see tag.
  class TextTag < SleepingKingStudios::Yard::Data::SeeTags::Base
    class << self
      # Checks if the given tag object is plain text.
      #
      # @param native [YARD::Tags::Tag] the tag object.
      #
      # @return [true, false] true if the tag object is plain text; otherwise
      #   false.
      def match?(native)
        native.name == '_'
      end
      alias matches? match?
    end

    # Generates a JSON-compatible representation of the tag.
    #
    # Returns a Hash with the following keys:
    #
    # - 'text': The text to display for the tag.
    def as_json
      { 'text' => text }
    end
  end
end
