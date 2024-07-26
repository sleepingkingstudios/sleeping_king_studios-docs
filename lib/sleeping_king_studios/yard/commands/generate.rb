# frozen_string_literal: true

require 'cuprum/command'
require 'sleeping_king_studios/tools/toolbelt'

require 'sleeping_king_studios/yard/commands'

module SleepingKingStudios::Yard::Commands
  # Generates YARD documentation files.
  class Generate < SleepingKingStudios::Yard::Commands::Generators::Base # rubocop:disable Metrics/ClassLength
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
      super(docs_path:, **options)

      @error_stream  = error_stream
      @output_stream = output_stream
    end

    private

    def build_constant(native:)
      SleepingKingStudios::Yard::Data::ConstantObject.new(native:)
    end

    def build_class(native:)
      SleepingKingStudios::Yard::Data::ClassObject.new(native:)
    end

    def build_method(native:)
      SleepingKingStudios::Yard::Data::MethodObject.new(native:)
    end

    def build_module(native:)
      SleepingKingStudios::Yard::Data::ModuleObject.new(native:)
    end

    def build_root_namespace(native:)
      SleepingKingStudios::Yard::Data::RootObject.new(native:)
    end

    def data_command
      @data_command ||=
        SleepingKingStudios::Yard::Commands::Generators::DataGenerator
        .new(docs_path:, **options)
    end

    def generate_classes
      puts "\nGenerating Classes:" if verbose? && !registry_classes.empty?

      registry_classes.each do |native|
        data_object = build_class(native:)

        puts "- #{data_object.name}" if verbose?

        generate_data_file(data_object:)
        generate_reference_file(data_object:)
      end
    end

    def generate_constants
      puts "\nGenerating Constants:" if verbose? && !registry_constants.empty?

      registry_constants.each do |native|
        data_object = build_constant(native:)

        puts "- #{data_object.name}" if verbose?

        generate_data_file(data_object:)
      end
    end

    def generate_data_file(data_object:, **options)
      report_result(
        command:     data_command,
        data_object:,
        result:      data_command.call(data_object:, **options),
        **options
      )
    end

    def generate_methods
      puts "\nGenerating Methods:" if verbose? && !registry_methods.empty?

      registry_methods.each do |native|
        data_object = build_method(native:)

        puts "- #{data_object.name}" if verbose?

        generate_data_file(data_object:)
      end
    end

    def generate_modules
      puts "\nGenerating Modules:" if verbose? && !registry_modules.empty?

      registry_modules.each do |native|
        data_object = build_module(native:)

        puts "- #{data_object.name}" if verbose?

        generate_data_file(data_object:)
        generate_reference_file(data_object:)
      end
    end

    def generate_reference_file(data_object:, **options)
      report_result(
        command:     reference_command,
        data_object:,
        result:      reference_command.call(
          data_object:,
          **options
        ),
        **options
      )
    end

    def generate_root_namespace
      puts 'Generating Root Namespace:' if verbose?

      data_object = build_root_namespace(native: registry_root)

      puts '- root namespace' if verbose?

      generate_data_file(data_object:, data_type: :namespace)
    end

    def parse_registry(file_path:)
      SleepingKingStudios::Yard::Commands::Parse.new.call(file_path)
    end

    def process(file_path: nil)
      step { parse_registry(file_path:) }

      generate_root_namespace
      generate_classes
      generate_constants
      generate_methods
      generate_modules

      nil
    end

    def puts(string)
      output_stream.puts(string)
    end

    def reference_command
      @reference_command ||=
        SleepingKingStudios::Yard::Commands::Generators::ReferenceGenerator
        .new(docs_path:, **options)
    end

    def registry
      SleepingKingStudios::Yard::Registry.instance
    end

    def registry_classes
      registry
        .select { |obj| obj.type == :class }
        .reject { |obj| obj.tags.any? { |tag| tag.tag_name == 'private' } }
        .sort_by(&:path)
    end

    def registry_constants
      registry
        .select { |obj| obj.type == :constant && obj.visibility == :public }
        .reject { |obj| obj.tags.any? { |tag| tag.tag_name == 'private' } }
        .sort_by(&:path)
    end

    def registry_methods
      registry
        .select { |obj| obj.type == :method && obj.visibility == :public }
        .reject { |obj| obj.tags.any? { |tag| tag.tag_name == 'private' } }
        .reject(&:is_alias?)
        .sort_by(&:path)
    end

    def registry_modules
      registry
        .select { |obj| obj.type == :module }
        .reject { |obj| obj.tags.any? { |tag| tag.tag_name == 'private' } }
        .sort_by(&:path)
    end

    def registry_root
      registry
        .find { |obj| obj.type == :root }
    end

    def report_failure(file_path:, result:)
      message = verbose? ? '  - ' : ''
      message +=
        "FAILURE: unable to write file to #{file_path} - " \
        "#{result.error.class}: #{result.error.message}"

      warn message
    end

    def report_result(command:, data_object:, result:, data_type: nil) # rubocop:disable Metrics/MethodLength
      data_type ||= data_object_type(data_object:)
      file_path   = command.file_path(
        data_object:,
        data_type:
      )

      if result.success?
        report_success(file_path:)
      else
        report_failure(file_path:, result:)
      end

      result
    end

    def report_success(file_path:)
      return unless verbose?

      message = "  - SUCCESS: file written to #{file_path}"

      puts message
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def warn(string)
      error_stream.puts(string)
    end
  end
end
