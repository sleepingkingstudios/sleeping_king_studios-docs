# frozen_string_literal: true

require 'sleeping_king_studios/docs/errors'

module SleepingKingStudios::Docs::Errors
  # Error returned when attempting to parse an invalid file or directory.
  class FileNotFound < SleepingKingStudios::Docs::Errors::FileError
    # Short string used to identify the type of error.
    TYPE = 'sleeping_king_studios.docs.errors.file_not_found'

    # @param path [String] the invalid file path.
    def initialize(path:)
      super(message: default_message(path), path:)
    end

    private

    def default_message(path)
      "file or directory not found at #{path.inspect}"
    end
  end
end
