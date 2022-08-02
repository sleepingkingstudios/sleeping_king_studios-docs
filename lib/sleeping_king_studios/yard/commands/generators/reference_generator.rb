# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/generators'

module SleepingKingStudios::Yard::Commands::Generators
  # Generator for writing reference files.
  class ReferenceGenerator <
        SleepingKingStudios::Yard::Commands::Generators::Base
    # @param docs_path [String] the directory path for generating the
    #   documentation files.
    # @param reference_class [Class] the class of the reference object used to
    #   generate the reference file.
    # @param reference_type [String, Symbol] the type of reference file to
    #   generate.
    # @param options [Hash] the configured options for the generator.
    #
    # @see SleepingKingStudios::Yard::Commands::Generators::Base#initialize
    def initialize(docs_path:, reference_class:, reference_type:, **options)
      super(docs_path: docs_path, **options)

      @reference_class = reference_class
      @reference_type  = reference_type
    end

    # @return [Class] the class of the reference object used to generate the
    #   reference file.
    attr_reader :reference_class

    # @return [String, Symbol] the type of reference file to generate.
    attr_reader :reference_type

    private

    def process(native:)
      reference_object = reference_class.new(native: native)

      write_data(reference_object: reference_object).tap do |result|
        file_path =
          File.join(reference_path, "#{reference_object.data_path}.md")
        message   = "#{reference_object.name} to #{file_path}"

        report(message: message, result: result)
      end
    end

    def reference_path
      if version
        File.join(docs_path, 'versions', version, 'reference')
      else
        File.join(docs_path, 'reference')
      end
    end

    def reference_template(reference_object:)
      <<~MARKDOWN
        ---
        data_path: "#{reference_object.data_path}"
        version: "#{version_string}"
        ---

        {% include templates/reference/#{reference_type}.md %}
      MARKDOWN
    end

    def write_command
      @write_command ||=
        SleepingKingStudios::Yard::Commands::WriteFile
        .new(force: force?)
    end

    def write_data(reference_object:)
      return success(nil) if dry_run?

      write_command.call(
        contents:  reference_template(reference_object: reference_object),
        file_path: File.join(reference_path, "#{reference_object.data_path}.md")
      )
    end
  end
end
