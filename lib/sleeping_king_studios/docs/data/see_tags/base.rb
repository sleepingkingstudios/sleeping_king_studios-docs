# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/see_tags'

module SleepingKingStudios::Docs::Data::SeeTags
  # Data object representing a plain text @see tag.
  #
  # @abstract
  class Base < SleepingKingStudios::Docs::Data::Base
    # @param native [YARD::Tags::Tag] the YARD object representing the @see tag.
    # @param parent [YARD::Tags::Tag] the YARD object representing the parent
    #   object, which contains the @see tag.
    def initialize(native:, parent:)
      super(native:)

      @parent = parent
    end

    # @return [YARD::Tags::Tag] the YARD object representing the parent object,
    #   which contains the @see tag.
    attr_reader :parent

    # The text to display when rendering the tag.
    #
    # @return [String] the text to display.
    def text
      @text ||= native.text
    end

    # @return [Boolean] true if the tag has display text, otherwise false.
    def text?
      !native.text.nil?
    end
  end
end
