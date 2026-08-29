# frozen_string_literal: true

require 'cuprum/cli'

require 'sleeping_king_studios/docs/jekyll/commands'

module SleepingKingStudios::Docs::Jekyll::Commands
  # Abstract base class for commands that update the reference documentation.
  class Reference < Cuprum::Cli::Command # rubocop:disable Metrics/ClassLength
    dependency :file_system
    dependency :standard_io

    include Cuprum::Cli::Dependencies::StandardIo::Helpers
    include Cuprum::Cli::Options::Quiet
    include Cuprum::Cli::Options::Verbose

    option :docs_path, default: 'docs'

    option :dry_run,   type: :boolean, default: false

    option :version

    # @return [String] the directory for defining class data YAML files.
    def class_data_directory
      @class_data_directory ||=
        if version
          File.join(docs_path, '_classes', "version--#{version}")
        else
          File.join(docs_path, '_classes')
        end
    end

    # @return [String] the directory for defining constant data YAML files.
    def constant_data_directory
      @constant_data_directory ||=
        if version
          File.join(docs_path, '_constants', "version--#{version}")
        else
          File.join(docs_path, '_constants')
        end
    end

    # @return [String] the directory for defining method data YAML files.
    def method_data_directory
      @method_data_directory ||=
        if version
          File.join(docs_path, '_methods', "version--#{version}")
        else
          File.join(docs_path, '_methods')
        end
    end

    # @return [String] the directory for defining module data YAML files.
    def module_data_directory
      @module_data_directory ||=
        if version
          File.join(docs_path, '_modules', "version--#{version}")
        else
          File.join(docs_path, '_modules')
        end
    end

    # @return [String] the directory for defining namespace data YAML files.
    def namespace_data_directory
      @namespace_data_directory ||=
        if version
          File.join(docs_path, '_namespaces', "version--#{version}")
        else
          File.join(docs_path, '_namespaces')
        end
    end

    # @return [String] the directory for defining reference Markdown files.
    def reference_directory
      @reference_directory ||=
        if version
          File.join(docs_path, 'versions', version, 'reference')
        else
          File.join(docs_path, 'reference')
        end
    end

    private

    def delete_directory(path, recursive: false)
      file_system.delete_directory(path, recursive:) unless dry_run?

      success(path)
    rescue Cuprum::Cli::Dependencies::FileSystem::FileError => exception
      error = SleepingKingStudios::Docs::Errors::FileError.new(
        message: exception.message,
        path:
      )
      failure(error)
    end

    def delete_file(path)
      file_system.delete_file(path) unless dry_run?

      say("  - Deleting file #{path}", verbose: true)

      success(path)
    rescue Cuprum::Cli::Dependencies::FileSystem::FileError => exception
      say("  - Unable to delete file #{path}", verbose: true)

      error = SleepingKingStudios::Docs::Errors::FileError.new(
        message: exception.message,
        path:
      )
      failure(error)
    end

    def each_data_directory(directory, &)
      pattern = File.join(directory, '*')
      enum    =
        file_system
        .each_file(pattern)
        .select { |path| file_system.directory?(path) }

      enum = enum.reject { |file| file.include?('version--') } unless version

      enum.each(&)
    end

    def each_data_file(directory, &)
      pattern = File.join(directory, '**/*')
      enum    =
        file_system
        .each_file(pattern)
        .select { |path| file_system.file?(path) }

      enum = enum.reject { |file| file.include?('version--') } unless version

      enum.each(&)
    end

    def each_reference_directory(&)
      pattern = File.join(reference_directory, '*')

      file_system
        .each_file(pattern)
        .select { |path| file_system.directory?(path) }
        .each(&)
    end

    def each_reference_file(&)
      pattern = File.join(reference_directory, '**/*')

      file_system
        .each_file(pattern)
        .select { |path| file_system.file?(path) }
        .reject { |path| path == File.join(reference_directory, 'index.md') }
        .each(&)
    end
  end
end
