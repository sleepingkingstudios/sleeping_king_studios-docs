# frozen_string_literal: true

require 'cuprum/command'
require 'cuprum/exception_handling'
require 'sleeping_king_studios/tools/toolbelt'

require 'sleeping_king_studios/yard/commands/generators'

module SleepingKingStudios::Yard::Commands::Generators
  # Abstract base class for writing generator classes.
  class Base < Cuprum::Command
    include Cuprum::ExceptionHandling

    # @overload initialize(docs_path:, **options)
    #   @param docs_path [String] the directory path for generating the
    #     documentation files.
    #   @param options [Hash] the configured options for the generator.
    #
    #   @option options dry_run [Boolean] if true, does not make any changes to
    #     the filesystem.
    #   @option options force [Boolean] if true, overwrites any existing files.
    #   @option options version [String] the code version for the generated
    #     documentation.
    #   @option options verbose [Boolean] if true, prints status messages to
    #     STDOUT.
    def initialize(
      docs_path:,
      error_stream:  $stderr,
      output_stream: $stdout,
      **options
    )
      super()

      @docs_path     = docs_path
      @options       = default_options.merge(
        tools.hash_tools.convert_keys_to_strings(options)
      )
      @error_stream  = error_stream
      @output_stream = output_stream
    end

    # @return [String] the directory path for generating the documentation
    #   files.
    attr_reader :docs_path

    # @return [Hash] the configured options for the generator.
    attr_reader :options

    # @return [Boolean] if true, does not make any changes to the filesystem.
    def dry_run?
      @options['dry_run']
    end

    # @return [Boolean] if true, overwrites any existing files.
    def force?
      @options['force']
    end

    # Writes the given string to STDOUT.
    #
    # @param string [String] the string to write.
    def print(string)
      output_stream.print(string)
    end

    # Writes the given string to STDOUT.
    #
    # Appends a trailing newline character `\n' if the string does not end with
    # a newline.
    #
    # @param string [String] the string to write.
    def puts(string)
      output_stream.puts(string)
    end

    # @return [Boolean] if true, prints status messages to STDOUT.
    def verbose?
      @options['verbose']
    end

    # @return [String] the code version for the generated documentation.
    def version
      @options['version']
    end

    # Writes the given string to STDERR.
    #
    # Appends a trailing newline character `\n' if the string does not end with
    # a newline.
    #
    # @param string [String] the string to write.
    def warn(string)
      error_stream.puts(string)
    end

    private

    attr_reader :error_stream

    attr_reader :output_stream

    def default_options
      {
        'dry_run' => false,
        'force'   => false,
        'verbose' => false
      }
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
