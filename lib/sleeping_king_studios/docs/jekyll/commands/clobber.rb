# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/commands'

module SleepingKingStudios::Docs::Jekyll::Commands
  # Clears out the existing reference documentation.
  class Clobber < SleepingKingStudios::Docs::Jekyll::Commands::Reference
    full_name 'docs:jekyll:clobber'

    description \
      'Removes any existing reference documentation for the current version'

    private

    attr_reader :errors

    def aggregate_errors
      result = yield

      errors << result.error if result.failure?

      result
    end

    def process
      @errors = []

      remove_reference_files

      remove_data_files(class_data_directory,     as: 'class')
      remove_data_files(constant_data_directory,  as: 'constant')
      remove_data_files(method_data_directory,    as: 'method')
      remove_data_files(module_data_directory,    as: 'module')
      remove_data_files(namespace_data_directory, as: 'namespace')

      report_errors
    end

    def remove_data_files(directory, as:) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      data_count = each_data_file(directory).count

      say "Removing #{data_count} #{as} objects from #{directory}..."
      say("\n", verbose: true) unless data_count.zero?

      each_data_file(directory) do |path|
        aggregate_errors { delete_file(path) }
      end

      each_data_directory(directory) do |path|
        aggregate_errors { delete_directory(path, recursive: true) }
      end

      if version && file_system.directory?(directory)
        aggregate_errors { delete_directory(directory) }
      end

      say("\n", verbose: true)
    end

    def remove_reference_files
      reference_count = each_reference_file.count

      say "Removing #{reference_count} files from #{reference_directory}..."
      say("\n", verbose: true) unless reference_count.zero?

      each_reference_file do |path|
        aggregate_errors { delete_file(path) }
      end

      each_reference_directory do |path|
        aggregate_errors { delete_directory(path, recursive: true) }
      end

      say("\n", verbose: true)
    end

    def report_errors # rubocop:disable Metrics/MethodLength
      if errors.empty?
        say 'Success!'

        return
      end

      warn 'Failures:'
      warn "\n"

      errors.each do |error|
        warn "  - Unable to remove #{error.path} - #{error.message}"
      end

      warn "\n"

      message = 'unable to remove documentation files'
      error   = Cuprum::Errors::MultipleErrors.new(errors:, message:)

      failure(error)
    end
  end
end
