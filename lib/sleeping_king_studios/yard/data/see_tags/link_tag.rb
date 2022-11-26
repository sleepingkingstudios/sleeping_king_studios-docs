# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tags'

module SleepingKingStudios::Yard::Data::SeeTags
  # Data object representing a @see tag with a link.
  class LinkTag < SleepingKingStudios::Yard::Data::SeeTags::Base
    # Pattern used to match external links. YARD seems to use the presence of a
    # protocol to identify a link, so "http://foo" is a valid link, but
    # "www.example.com" is not.
    LINK_PATTERN = %r{\A\w+://\w+}.freeze
    private_constant :LINK_PATTERN

    class << self
      # Checks if the given tag object is a link.
      #
      # @param native [YARD::Tags::Tag] the tag object.
      #
      # @return [true, false] true if the tag object is a link; otherwise false.
      def match?(native)
        native.name.match?(LINK_PATTERN)
      end
      alias matches? match?
    end

    # Generates a JSON-compatible representation of the tag.
    #
    # Returns a Hash with the following keys:
    #
    # - 'label': The label used to generate the link.
    # - 'path': The path used to generate the link.
    # - 'text': The text to display for the tag.
    # - 'type': The string 'link'.
    def as_json
      {
        'label' => label,
        'path'  => path,
        'text'  => text,
        'type'  => 'link'
      }
    end

    # @return [String] the label used to generate the link.
    def label
      path
    end

    # @return [String] the path used to generate the link.
    def path
      @path ||= native.name.sub(/\.\z/, '')
    end
  end
end
