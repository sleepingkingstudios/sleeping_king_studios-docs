# frozen_string_literal: true

require 'cuprum/command'

require 'sleeping_king_studios/yard/commands/generators'

module SleepingKingStudios::Yard::Commands::Generators
  # Abstract base class for writing generator classes.
  class Base < Cuprum::Command
    # @param docs_path [String] the directory path for generating the
    #   documentation files.
    # @param options [Hash] the configured options for the generator.
    #
    # @option options dry_run [Boolean] if true, does not make any changes to
    #   the filesystem.
    # @option options force [Boolean] if true, overwrites any existing files.
    # @option options version [String] the code version for the generated
    #   documentation.
    # @option options verbose [Boolean] if true, prints status messages to
    #   STDOUT.
    def initialize(docs_path:, **options)
      super()

      @docs_path = docs_path
      @options   = default_options.merge(
        tools.hash_tools.convert_keys_to_strings(options)
      )
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

    # @return [Boolean] if true, prints status messages to STDOUT.
    def verbose?
      @options['verbose']
    end

    # @return [String] the code version for the generated documentation.
    def version
      @options['version']
    end

    private

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
