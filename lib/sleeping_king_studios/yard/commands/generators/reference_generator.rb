# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/generators'

module SleepingKingStudios::Yard::Commands::Generators
  # Generator for writing reference files.
  class ReferenceGenerator <
        SleepingKingStudios::Yard::Commands::Generators::Base
    # @overload file_path(data_object:)
    #   Determines the generated file path for the given data object.
    #
    #   @param data_object [SleepingKingStudios::Yard::Data::Base] the data
    #     object for which the file is generated.
    #
    #   @return [String] the qualified path to the generated file.
    def file_path(data_object:, data_type: nil) # rubocop:disable Lint/UnusedMethodArgument
      File.join(dir_path, "#{data_object.data_path}.md")
    end

    private

    def dir_path
      if version
        File.join(docs_path, 'versions', version, 'reference')
      else
        File.join(docs_path, 'reference')
      end
    end

    def process(data_object:, data_type: nil)
      data_type ||= data_object_type(data_object:)
      contents    = template(data_object:, data_type:)

      return success(nil) if dry_run?

      write_command.call(
        contents:,
        file_path: file_path(data_object:)
      )
    end

    def template(data_object:, data_type:)
      <<~MARKDOWN
        ---
        data_path: "#{data_object.data_path}"
        version: "#{version_string}"
        ---

        {% include #{template_path}/#{data_type}.md %}
      MARKDOWN
    end

    def write_command
      @write_command ||=
        SleepingKingStudios::Yard::Commands::WriteFile
        .new(force: force?)
    end
  end
end
