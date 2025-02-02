# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/installation'
require 'sleeping_king_studios/yard/errors/file_already_exists'

module SleepingKingStudios::Yard::Commands::Installation
  # Installs the Liquid template files.
  class InstallTemplates < Cuprum::Command
    # @overload initialize(**options)
    #   @option options dry_run [Boolean] if true, does not apply filesystem
    #     changes. Defaults to false.
    #   @option options force [Boolean] if true, overwrites existing template
    #     files. Defaults to false.
    #   @param option options verbose [Boolean] if true, prints updates to
    #     STDOUT. Defaults to true.
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

    attr_reader :docs_path

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

    def copy_template(template_path)
      install_path  = File.join(docs_path, '_includes')
      relative_path = template_path.sub("#{templates_path}/", '')
      absolute_path = File.join(install_path, relative_path)

      output "  - Copying template #{relative_path}"

      step { check_for_existing_file(absolute_path) }

      FileUtils.mkdir_p(File.dirname(absolute_path)) unless dry_run?
      FileUtils.copy(template_path, absolute_path) unless dry_run?
    end

    def each_template(&)
      return enum_for(:each_template) unless block_given?

      Dir[templates_pattern].each(&)
    end

    def output(string)
      return unless verbose?

      output_stream.puts(string)
    end

    def process(docs_path:)
      @docs_path = docs_path

      output "Copying template files (force=#{force?})..."

      each_template { |template_path| step { copy_template(template_path) } }

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

    def templates_pattern
      @templates_pattern ||= File.join(templates_path, '**', '*.md')
    end
  end
end
