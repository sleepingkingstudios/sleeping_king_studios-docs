# frozen_string_literal: true

require 'cuprum/error'

require 'sleeping_king_studios/yard/errors'

module SleepingKingStudios::Yard::Errors
  # Abstract base class for errors interacting with the file system.
  class FileError < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'sleeping_king_studios.yard.errors.file_error'

    # @param message [String] message describing the nature of the error.
    # @param path [String] the invalid file or directory path.
    def initialize(message:, path:)
      super(message:)

      @path = path
    end

    # @return [String] the invalid file or directory path.
    attr_reader :path

    private

    def as_json_data
      { 'path' => path.to_s }
    end
  end
end
