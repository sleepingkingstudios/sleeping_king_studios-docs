# frozen_string_literal: true

require 'cuprum/cli'

require 'sleeping_king_studios/docs/jekyll/commands'

module SleepingKingStudios::Docs::Jekyll::Commands
  # Command for installing or updating Jekyll templates for docs.
  class InstallTemplates < Cuprum::Cli::Command
    dependency :file_system
    dependency :standard_io

    include Cuprum::Cli::Dependencies::StandardIo::Helpers
    include Cuprum::Cli::Options::Quiet
    include Cuprum::Cli::Options::Verbose

    full_name 'docs:jekyll:install_templates'

    description 'Installs or updates the Jekyll templates'

    option :docs_path,       type: :string,  default: 'docs'

    option :dry_run,         type: :boolean, default: false

    option :force,           type: :boolean, default: false

    option :ignore_existing, type: :boolean, default: false

    private

    def copy_template(template_path)
      relative_path = template_path[(templates_path.size + 1)...]
      output_path   = File.join(includes_path, relative_path)

      return success(nil) if ignore_existing? && file_system.file?(output_path)

      handle_file_error(output_path) do
        write_template_file(output_path:, template_path:) unless dry_run?

        say("  - Copying template #{relative_path}", verbose: true)
      end
    end

    def copy_templates # rubocop:disable Metrics/MethodLength
      output_paths = []
      errors       = []

      template_files.each do |template_path|
        result = copy_template(template_path)

        if result.success?
          output_paths << result.value
        else
          errors << result.error
        end
      end

      [output_paths, errors]
    end

    def handle_errors(errors:, output_paths:) # rubocop:disable Metrics/MethodLength
      return success(output_paths) if errors.empty?

      error =
        if errors.size == 1
          errors.first
        else
          Cuprum::Errors::MultipleErrors.new(
            errors:,
            message: 'unable to copy multiple template files'
          )
        end

      build_result(error:, value: output_paths)
    end

    def handle_file_error(file_path)
      yield

      success(file_path)
    rescue Cuprum::Cli::Dependencies::FileSystem::FileError => exception
      warn("  ! #{exception.message}")

      error = Cuprum::Cli::Files::Errors::FileNotWriteable.new(
        file_path:,
        message:   exception.message
      )
      failure(error)
    end

    def includes_path
      @includes_path ||= File.join(docs_path, '_includes')
    end

    def process
      say "Copying template files (force=#{force?})..."
      say("\n", verbose: true)

      output_paths, errors = copy_templates

      handle_errors(errors:, output_paths:)
    end

    def template_files
      return @template_files if @template_files

      pattern = "#{templates_path}/**/*.md"

      @template_files = file_system.each_file(pattern).to_a
    end

    def templates_path
      File.join(
        SleepingKingStudios::Docs.gem_path,
        'lib',
        'sleeping_king_studios',
        'docs',
        'templates',
        'includes'
      )
    end

    def write_template_file(output_path:, template_path:)
      file_system.create_directory(File.dirname(output_path), recursive: true)

      file_system.copy_file(template_path, output_path, force: force?)
    end
  end
end
