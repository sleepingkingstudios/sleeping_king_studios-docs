# frozen_string_literal: true

require 'cuprum/cli'
require 'cuprum/command'
require 'plumbum'
require 'yard'

require 'sleeping_king_studios/docs/yard'

module SleepingKingStudios::Docs::Yard
  # Adds the specified data to the YARD Registry.
  class Parse < Cuprum::Command
    include Plumbum::Consumer
    prepend Plumbum::Parameters

    dependency :file_system

    provider Cuprum::Cli::Dependencies.provider

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
      if path
        step { validate_file_path(path) }

        ::YARD.parse(path)
      else
        ::YARD.parse
      end

      SleepingKingStudios::Docs::Yard::Registry.build
    end

    def validate_file_path(path)
      return if file_system.directory?(path) || file_system.file?(path)

      failure(file_not_found_error(path))
    end
  end
end
