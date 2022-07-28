# frozen_string_literal: true

require 'fileutils'

require 'cuprum/command'
require 'cuprum/exception_handling'

require 'sleeping_king_studios/yard/commands'

module SleepingKingStudios::Yard::Commands
  # Writes the given contents to a file.
  class WriteFile < Cuprum::Command
    include Cuprum::ExceptionHandling

    # @param force [Boolean] if true, overwrites an existing file.
    def initialize(force: false)
      super()

      @force = force
    end

    # @return [Boolean] if true, overwrites an existing file.
    def force?
      @force
    end

    private

    def check_if_file_exists(file_path:)
      return if     force?
      return unless File.exist?(file_path)

      error =
        SleepingKingStudios::Yard::Errors::FileAlreadyExists
        .new(path: file_path)

      failure(error)
    end

    def create_directory(file_path:)
      dir_path = File.dirname(file_path)

      FileUtils.mkdir_p(dir_path)
    rescue Errno::EEXIST => exception
      failure(invalid_directory_error(exception))
    end

    def create_file(contents:, file_path:)
      File.write(file_path, contents)
    rescue Errno::EISDIR => exception
      failure(invalid_file_error(exception))
    end

    def invalid_directory_error(exception)
      dir_path = exception.message.split(' - ').last

      SleepingKingStudios::Yard::Errors::InvalidDirectory.new(path: dir_path)
    end

    def invalid_file_error(exception)
      file_path = exception.message.split(' - ').last

      SleepingKingStudios::Yard::Errors::InvalidFile.new(path: file_path)
    end

    def process(contents:, file_path:)
      file_path = File.expand_path(file_path)

      step { check_if_file_exists(file_path: file_path) }

      step { create_directory(file_path: file_path) }

      step { create_file(contents: contents, file_path: file_path) }
    end
  end
end
