# frozen_string_literal: true

require 'sleeping_king_studios/yard/errors'

module SleepingKingStudios::Yard::Errors
  # Error returned when attempting to create an existing file.
  class FileAlreadyExists < SleepingKingStudios::Yard::Errors::FileError
    # Short string used to identify the type of error.
    TYPE = 'sleeping_king_studios.yard.errors.file_already_exists'

    # @param path [String] the invalid file path.
    def initialize(path:)
      super(message: default_message(path), path:)
    end

    private

    def default_message(path)
      "file already exists at #{path.inspect}"
    end
  end
end
