# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/commands'

module SleepingKingStudios::Docs::Jekyll::Commands
  # Generates new reference documentation.
  class Generate < SleepingKingStudios::Docs::Jekyll::Commands::Reference # rubocop:disable Metrics/ClassLength
    full_name 'docs:jekyll:generate'

    description 'Generates reference documentation for the current version'

    option :file_path, type: :string

    private

    attr_reader :errors

    attr_reader :files

    attr_reader :registry

    def build_command
      @build_command ||= SleepingKingStudios::Docs::Yard::Build.new
    end

    def clear_data_directory(path) # rubocop:disable Metrics/MethodLength
      return unless file_system.directory?(path)

      if dry_run?
        step { ensure_data_directory_empty(path) }

        return
      end

      each_data_directory(path) do |child|
        file_system.delete_directory(child, recursive: true)
      end
    rescue Cuprum::Cli::Dependencies::FileSystem::FileError => exception
      error = SleepingKingStudios::Docs::Errors::FileError.new(
        message: exception.message,
        path:
      )
      failure(error)
    end

    def clear_directories
      step { clear_reference_directory }

      step { clear_data_directory(class_data_directory) }
      step { clear_data_directory(constant_data_directory) }
      step { clear_data_directory(method_data_directory) }
      step { clear_data_directory(module_data_directory) }
      step { clear_data_directory(namespace_data_directory) }
    end

    def clear_reference_directory # rubocop:disable Metrics/MethodLength
      return unless file_system.directory?(reference_directory)

      if dry_run?
        step { ensure_reference_directory_empty }

        return
      end

      each_reference_directory do |path|
        file_system.delete_directory(path, recursive: true)
      end
    rescue Cuprum::Cli::Dependencies::FileSystem::FileError => exception
      error = SleepingKingStudios::Docs::Errors::FileError.new(
        message: exception.message,
        path:    reference_directory
      )
      failure(error)
    end

    def ensure_data_directory_empty(path)
      matching = each_data_file(path).first

      return unless matching

      path = File.dirname(matching)

      message = "unable to delete directory #{path} - directory is not empty"
      error   = SleepingKingStudios::Docs::Errors::FileError.new(
        message:,
        path:
      )

      failure(error)
    end

    def ensure_reference_directory_empty # rubocop:disable Metrics/MethodLength
      matching = each_reference_file.first

      return unless matching

      path = File.dirname(matching)

      message =
        "unable to delete directory #{path} - directory is " \
        'not empty'
      error   = SleepingKingStudios::Docs::Errors::FileError.new(
        message:,
        path:
      )

      failure(error)
    end

    def generator_for(object)
      namespace       = SleepingKingStudios::Docs::Jekyll::Generators
      generator_class =
        if object.is_a?(SleepingKingStudios::Docs::Data::ModuleObject)
          namespace::ReferenceGenerator
        else
          namespace::DataGenerator
        end

      generator_class.new(object:, **generator_options)
    end

    def generator_options
      @generator_options ||= {
        file_system:,
        standard_io:,
        docs_path:,
        dry_run:     dry_run?,
        quiet:       quiet?,
        verbose:     verbose?,
        version:
      }
    end

    def handle_generator_result
      result = yield

      if result.success?
        files.concat(result.value)

        return
      end

      errors << result.error
    end

    def parse_registry
      @registry = step do
        SleepingKingStudios::Docs::Yard::Parse.new.call(file_path)
      end

      SleepingKingStudios::Docs::Yard::Registry
        .provider
        .set(:registry, registry)
    rescue Plumbum::Errors::ImmutableError => exception
      message = "#{exception.class}: #{exception.message}"
      error   = SleepingKingStudios::Docs::Errors::RegistryError.new(message:)

      failure(error)
    end

    def process # rubocop:disable Metrics/MethodLength
      @files  = []
      @errors = []

      step { clear_directories }

      step { parse_registry }

      registry.each do |native|
        data = step { build_command.call(native) }

        next unless data.public?

        generator = generator_for(data)

        handle_generator_result { generator.call }
      end

      report_errors
    end

    def report_errors # rubocop:disable Metrics/MethodLength
      if errors.empty?
        say 'Success!'

        return files
      end

      warn 'Failures:'
      warn "\n"

      errors.each do |error|
        warn "  - Unable to generate file #{error.path} - #{error.message}"
      end

      warn "\n"

      message = 'unable to generate documentation files'
      error   = Cuprum::Errors::MultipleErrors.new(errors:, message:)

      failure(error)
    end
  end
end
