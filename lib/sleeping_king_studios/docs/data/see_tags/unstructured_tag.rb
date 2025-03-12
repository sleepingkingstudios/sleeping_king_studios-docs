# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/see_tags'

module SleepingKingStudios::Docs::Data::SeeTags
  # Data object representing an unstructured @see tag.
  class UnstructuredTag < SleepingKingStudios::Docs::Data::SeeTags::Base
    class << self
      # @overload match?(native)
      #   Always returns true.
      #
      #   @param native [YARD::Tags::Tag] the tag object.
      #
      #   @return [true] true for all tags.
      def match?(_native)
        true
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

    # The text to display when rendering the tag.
    #
    # @return [String] the text to display.
    def text
      @text ||= "#{native.name} #{native.text}".strip
    end
  end
end
