# frozen_string_literal: true

require 'sleeping_king_studios/docs/errors'

module SleepingKingStudios::Docs::Errors
  # Error returned when attempting to create an invalid file.
  class InvalidFile < SleepingKingStudios::Docs::Errors::FileError
    # Short string used to identify the type of error.
    TYPE = 'sleeping_king_studios.docs.errors.invalid_file'

    # @param path [String] the invalid file path.
    def initialize(path:)
      super(message: default_message(path), path:)
    end

    private

    def default_message(path)
      "directory already exists at #{path.inspect}"
    end
  end
end
