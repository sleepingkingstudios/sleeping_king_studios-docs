# frozen_string_literal: true

require 'yaml'

require 'sleeping_king_studios/tools/toolbelt'

require 'sleeping_king_studios/yard/commands/generators'

module SleepingKingStudios::Yard::Commands::Generators
  # Generator for writing data files.
  class DataGenerator < SleepingKingStudios::Yard::Commands::Generators::Base
    # Determines the generated file path for the given data object.
    #
    # @param data_object [SleepingKingStudios::Yard::Data::Base] the data object
    #   for which the file is generated.
    # @param data_type [String, Symbol] the type of data file to generate.
    #
    # @return [String] the qualified path to the generated file.
    def file_path(data_object:, data_type: nil)
      data_type ||= data_object_type(data_object: data_object)

      File.join(dir_path(data_type), "#{data_object.data_path}.yml")
    end

    private

    def dir_path(data_type)
      scope = "_#{tools.string_tools.pluralize(data_type.to_s)}"

      if version
        File.join(docs_path, scope, "version--#{version}")
      else
        File.join(docs_path, scope)
      end
    end

    def file_data(data_object:)
      data_object
        .as_json
        .merge('version' => version_string)
    end

    def process(data_object:, data_type: nil)
      data        = file_data(data_object: data_object)
      data_type ||= data_object_type(data_object: data_object)

      return success(nil) if dry_run?

      write_command.call(
        contents:  YAML.dump(data),
        file_path: file_path(
          data_object: data_object,
          data_type:   data_type
        )
      )
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def write_command
      @write_command ||=
        SleepingKingStudios::Yard::Commands::WriteFile
        .new(force: force?)
    end
  end
end
