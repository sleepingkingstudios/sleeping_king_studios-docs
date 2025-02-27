# frozen_string_literal: true

require 'cuprum/command'
require 'yard'

require 'sleeping_king_studios/docs/commands'

module SleepingKingStudios::Docs::Commands
  # Adds the specified data to the YARD Registry.
  class Parse < Cuprum::Command
    # @!method call
    #   @overload call
    #     Parses the working directory per YARD defaults.
    #
    #     @return [Cuprum::Result<Module>] an empty result.
    #
    #   @overload call(path)
    #     Parses the given file or directory.
    #
    #     @return [Cuprum::Result<nil>] an empty result if the parse is
    #       successful.
    #     @return [Cuprum::Result<Cuprum::Error>] a failing result if the file
    #       or directory path is invalid.

    private

    def file_not_found_error(path)
      SleepingKingStudios::Docs::Errors::FileNotFound.new(path:)
    end

    def process(path = nil)
      if path.nil?
        ::YARD.parse

        return success(nil)
      end

      step { validate_file_path(path) }

      ::YARD.parse(path)

      success(nil)
    end

    def validate_file_path(path)
      return if File.exist?(path)

      failure(file_not_found_error(path))
    end
  end
end
