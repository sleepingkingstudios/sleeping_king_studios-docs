# frozen_string_literal: true

require 'sleeping_king_studios/yard/errors'

module SleepingKingStudios::Yard::Errors
  # Error returned when attempting to create an invalid file.
  class InvalidFile < SleepingKingStudios::Yard::Errors::FileError
    # Short string used to identify the type of error.
    TYPE = 'sleeping_king_studios.yard.errors.invalid_file'

    # @param path [String] the invalid file path.
    def initialize(path:)
      super(message: default_message(path), path: path)
    end

    private

    def default_message(path)
      "directory already exists at #{path.inspect}"
    end
  end
end
