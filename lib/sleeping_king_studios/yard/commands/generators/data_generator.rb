# frozen_string_literal: true

require 'yaml'

require 'sleeping_king_studios/tools/toolbelt'

require 'sleeping_king_studios/yard/commands/generators'

module SleepingKingStudios::Yard::Commands::Generators
  # Generator for writing data files.
  class DataGenerator < SleepingKingStudios::Yard::Commands::Generators::Base
    # @param data_class [Class] the class of the data object used to generate
    #   the data file.
    # @param data_type [String, Symbol] the type of data file to generate.
    # @param docs_path [String] the directory path for generating the
    #   documentation files.
    # @param options [Hash] the configured options for the generator.
    #
    # @see SleepingKingStudios::Yard::Commands::Generators::Base#initialize
    def initialize(data_class:, data_type:, docs_path:, **options)
      super(docs_path: docs_path, **options)

      @data_class = data_class
      @data_type  = data_type
    end

    # @return [Class] the class of the data object used to generate the data
    #   file.
    attr_reader :data_class

    # @return [String, Symbol] the type of data file to generate.
    attr_reader :data_type

    private

    def data_path
      scope = "_#{tools.string_tools.pluralize(data_type.to_s)}"

      if version
        File.join(docs_path, scope, '_versions', version)
      else
        File.join(docs_path, scope)
      end
    end

    def process(native:)
      data_object = data_class.new(native: native)

      write_data(data_object: data_object).tap do |result|
        file_path = File.join(data_path, "#{data_object.data_path}.yml")
        message   = "#{data_object.name} to #{file_path}"

        report(message: message, result: result)
      end
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def write_command
      @write_command ||=
        SleepingKingStudios::Yard::Commands::WriteFile
        .new(force: force?)
    end

    def write_data(data_object:)
      return success(nil) if dry_run?

      data =
        data_object
        .as_json
        .merge('version' => version_string)

      write_command.call(
        contents:  YAML.dump(data),
        file_path: File.join(data_path, "#{data_object.data_path}.yml")
      )
    end
  end
end
