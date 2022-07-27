# frozen_string_literal: true

require 'cuprum/error'

require 'sleeping_king_studios/yard/errors'

module SleepingKingStudios::Yard::Errors
  # Error representing an invalid file or directory path.
  class InvalidPath < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'sleeping_king_studios.yard.errors.invalid_path'

    # @param message [String] an additional message to display.
    # @param path [String] the invalid file or directory path.
    def initialize(path:, message: nil)
      @path = path

      super(message: generate_message(message))
    end

    # @return [String] the invalid file or directory path.
    attr_reader :path

    private

    def as_json_data
      { 'path' => path.to_s }
    end

    def generate_message(message)
      str = "invalid file or directory path #{path.inspect}"

      return str unless message

      "#{str} - #{message}"
    end
  end
end
