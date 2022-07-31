# frozen_string_literal: true

require 'yaml'

require 'sleeping_king_studios/yard/commands/generators'

module SleepingKingStudios::Yard::Commands::Generators
  # Generates files for a documented method.
  class MethodGenerator < SleepingKingStudios::Yard::Commands::Generators::Base
    private

    def data_path
      if version
        File.join(docs_path, '_methods', version)
      else
        File.join(docs_path, '_methods')
      end
    end

    def process(native:)
      method_object =
        SleepingKingStudios::Yard::Data::MethodObject
        .new(native: native)

      write_data(method_object: method_object).tap do |result|
        report_data(method_object: method_object, result: result)
      end
    end

    def report_data(method_object:, result:)
      file_path = File.join(data_path, "#{method_object.data_path}.yml")
      message   = "#{method_object.name} to #{file_path}"

      report(message: message, result: result)
    end

    def write_command
      @write_command ||=
        SleepingKingStudios::Yard::Commands::WriteFile
        .new(force: force?)
    end

    def write_data(method_object:)
      return success(nil) if dry_run?

      data =
        method_object
        .as_json
        .merge('version' => version_string)

      write_command.call(
        contents:  YAML.dump(data),
        file_path: File.join(data_path, "#{method_object.data_path}.yml")
      )
    end
  end
end
