# frozen_string_literal: true

require 'cuprum/command'
require 'cuprum/exception_handling'
require 'sleeping_king_studios/tools/toolbelt'

require 'sleeping_king_studios/docs/commands/generators'

module SleepingKingStudios::Docs::Commands::Generators
  # Abstract base class for writing generator classes.
  class Base < Cuprum::Command
    include Cuprum::ExceptionHandling

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
      @options   = default_options.merge(options)
    end

    # @return [String] the directory path for generating the documentation
    #   files.
    attr_reader :docs_path

    # @return [Hash] the configured options for the generator.
    attr_reader :options

    # @return [Boolean] if true, does not make any changes to the filesystem.
    def dry_run?
      @options[:dry_run]
    end

    # @return [Boolean] if true, overwrites any existing files.
    def force?
      @options[:force]
    end

    # @return [String] the relative path to the Jekyll templates for each data
    #   type.
    def template_path
      @options.fetch(:template_path, 'reference')
    end

    # @return [Boolean] if true, prints status messages to STDOUT.
    def verbose?
      @options[:verbose]
    end

    # @return [String] the code version for the generated documentation.
    def version
      @options[:version]
    end

    private

    attr_reader :error_stream

    attr_reader :output_stream

    def data_object_type(data_object:)
      data_object
        .class
        .name
        .split('::')
        .last
        .then { |str| str[0...-6] }
        .then { |str| tools.string_tools.underscore(str) }
    end

    def default_options
      {
        dry_run: false,
        force:   false,
        verbose: false
      }
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def version_string
      version || '*'
    end
  end
end
