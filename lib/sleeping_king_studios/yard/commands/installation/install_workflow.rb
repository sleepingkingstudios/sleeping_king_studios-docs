# frozen_string_literal: true

require 'fileutils'

require 'erubi'

require 'sleeping_king_studios/yard/commands/installation'
require 'sleeping_king_studios/yard/errors/file_already_exists'

module SleepingKingStudios::Yard::Commands::Installation
  # Installs the GitHub pages CI workflow.
  class InstallWorkflow < Cuprum::Command
    # @overload initialize(**options)
    #   @param options [Hash] additional options for the command.
    #
    #   @option options dry_run [Boolean] if true, does not apply filesystem
    #     changes. Defaults to false.
    #   @option options force [Boolean] if true, replaces existing template
    #     files.
    #   @option options verbose [Boolean] if true, prints updates to STDOUT.
    #     Defaults to true.
    def initialize(error_stream: $stderr, output_stream: $stdout, **options)
      super()

      @error_stream  = error_stream
      @output_stream = output_stream
      @options       = options
    end

    # @return [Boolean] if true, does not apply filesystem changes.
    def dry_run?
      @options.fetch(:dry_run, false)
    end

    # @return [Boolean] if true, overwrites existing template files.
    def force?
      @options.fetch(:force, false)
    end

    # @return [Boolean] if true, prints updates to STDOUT.
    def verbose?
      @options.fetch(:verbose, true)
    end

    private

    attr_reader :error_stream

    attr_reader :output_stream

    def check_for_existing_file(filename)
      return if force?
      return unless File.exist?(filename)

      error =
        SleepingKingStudios::Yard::Errors::FileAlreadyExists
        .new(path: filename)

      error_stream.puts("Error: #{error.message}")

      failure(error)
    end

    def create_workflow(workflow_path)
      file_path = File.join(workflow_path, 'deploy-pages.yml')

      step { check_for_existing_file(file_path) }

      return if dry_run?

      File.write(
        file_path,
        evaluate_template(File.join(templates_path, 'deploy-pages.yml.erb'))
      )
    end

    def evaluate_template(template_path)
      template = File.read(template_path)
      engine   = Erubi::Engine.new(template).src

      eval(engine, local_binding) # rubocop:disable Security/Eval
    end

    def local_binding
      return @local_binding if @local_binding

      ruby_version = RUBY_VERSION.split('.')[0..1].join('.')

      @local_binding = binding
    end

    def output(string)
      return unless verbose?

      output_stream.puts(string)
    end

    def process(root_path: Dir.pwd)
      workflow_path = File.join(root_path, '.github', 'workflows')

      output 'Adding GitHub pages workflow...'

      FileUtils.mkdir_p(workflow_path) unless dry_run?

      step { create_workflow(workflow_path) }

      output 'Done!'
    end

    def templates_path
      @templates_path ||=
        File.join(
          SleepingKingStudios::Yard.gem_path,
          'lib',
          'sleeping_king_studios',
          'yard',
          'templates'
        )
    end
  end
end
