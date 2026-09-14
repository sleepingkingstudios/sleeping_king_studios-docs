# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/generators'

module SleepingKingStudios::Docs::Jekyll::Generators
  # Generator class for writing reference data and files to the filesystem.
  class ReferenceGenerator < SleepingKingStudios::Docs::Jekyll::Generators::DataGenerator # rubocop:disable Layout/LineLength
    REFERENCE_TEMPLATE = Cuprum::Cli::Files::Templates::StringTemplate.new(
      engine:       Cuprum::Cli::Files::Engines::ERB,
      raw_template: <<~MARKDOWN
        ---
        data_path: "<%= object_path %>"
        version: "<%= version_string %>"
        ---

        {% include reference/<%= data_type %>.md %}
      MARKDOWN
    ).freeze
    private_constant :REFERENCE_TEMPLATE

    output '%<reference_path>s/%<object_path>s.md',
      key:      :reference,
      template: REFERENCE_TEMPLATE

    # @return [Hash] parameters used to resolve output file paths and contents.
    def parameters
      super.merge(data_type:, reference_path:, version_string:)
    end

    private

    def reference_path
      if version
        File.join(docs_path, 'versions', version, 'reference')
      else
        File.join(docs_path, 'reference')
      end
    end
  end
end
