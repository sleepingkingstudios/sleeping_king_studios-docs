# frozen_string_literal: true

require 'yaml'

require 'sleeping_king_studios/yard/commands/generators'

module SleepingKingStudios::Yard::Commands::Generators
  # Generates documentation files for a documented method.
  class MethodGenerator < SleepingKingStudios::Yard::Commands::Generators::Base
    private

    def data_path
      File.join(docs_path, '_methods', version || 'current')
    end

    def method_data(method_object:)
      data = method_object.as_json

      return data unless version

      data.merge('version' => version)
    end

    def process(native:)
      method_object =
        SleepingKingStudios::Yard::Data::MethodObject
        .new(native: native)
      yaml_path     = File.join(data_path, "#{method_object.data_path}.yml")
      result        = write_data(
        data:      method_data(method_object: method_object),
        file_path: yaml_path
      )

      report(native: native, result: result, yaml_path: yaml_path)

      result
    end

    def report(native:, result:, yaml_path:)
      if verbose? && result.success?
        puts("- #{native.path} to #{yaml_path}")
      elsif result.failure?
        warn(
          "- ERROR: #{native.path} to #{yaml_path}: #{result.error.message}"
        )
      end
    end

    def write_command
      @write_command ||=
        SleepingKingStudios::Yard::Commands::WriteFile
        .new(force: force?)
    end

    def write_data(data:, file_path:)
      return success(nil) if dry_run?

      write_command.call(
        contents:  YAML.dump(data),
        file_path: file_path
      )
    end
  end
end
