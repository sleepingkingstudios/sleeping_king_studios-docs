# frozen_string_literal: true

require 'yaml'

require 'sleeping_king_studios/yard/commands/generators'

module SleepingKingStudios::Yard::Commands::Generators
  # Generates files for a documented module.
  class ModuleGenerator < SleepingKingStudios::Yard::Commands::Generators::Base
    private

    def build_reference(module_object:)
      <<~MARKDOWN
        ---
        data_path: "#{module_object.data_path}"
        version: "#{version_string}"
        ---

        {% include templates/reference/module.md %}
      MARKDOWN
    end

    def data_path
      if version
        File.join(docs_path, '_modules', '_versions', version)
      else
        File.join(docs_path, '_modules')
      end
    end

    def process(native:) # rubocop:disable Metrics/MethodLength
      module_object =
        SleepingKingStudios::Yard::Data::ModuleObject
        .new(native: native)

      results = []

      step do
        results << write_data(module_object: module_object).tap do |result|
          report_data(module_object: module_object, result: result)
        end
      end

      step do
        results << write_file(module_object: module_object).tap do |result|
          report_file(module_object: module_object, result: result)
        end
      end

      Cuprum::ResultList.new(*results)
    end

    def refs_path
      if version
        File.join(docs_path, 'versions', version, 'reference')
      else
        File.join(docs_path, 'reference')
      end
    end

    def report_data(module_object:, result:)
      file_path = File.join(data_path, "#{module_object.data_path}.yml")
      message   = "#{module_object.name} to #{file_path}"

      report(message: message, result: result)
    end

    def report_file(module_object:, result:)
      file_path = File.join(refs_path, "#{module_object.data_path}.md")
      message   = "#{module_object.name} to #{file_path}"

      report(message: message, result: result)
    end

    def write_command
      @write_command ||=
        SleepingKingStudios::Yard::Commands::WriteFile
        .new(force: force?)
    end

    def write_data(module_object:)
      return success(nil) if dry_run?

      data =
        module_object
        .as_json
        .merge('version' => version_string)

      write_command.call(
        contents:  YAML.dump(data),
        file_path: File.join(data_path, "#{module_object.data_path}.yml")
      )
    end

    def write_file(module_object:)
      return success(nil) if dry_run?

      write_command.call(
        contents:  build_reference(module_object: module_object),
        file_path: File.join(refs_path, "#{module_object.data_path}.md")
      )
    end
  end
end
