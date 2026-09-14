# frozen_string_literal: true

require 'yaml'

require 'sleeping_king_studios/docs/jekyll/generators'

module SleepingKingStudios::Docs::Jekyll::Generators
  # Generator class for writing reference data to the filesystem.
  class DataGenerator < Cuprum::Cli::Files::Generator
    DATA_TEMPLATE = Cuprum::Cli::Files::Templates::StringTemplate.new(
      engine:       Cuprum::Cli::Files::Engines::ERB,
      raw_template: '<%= data_contents %>'
    ).freeze
    private_constant :DATA_TEMPLATE

    option :docs_path,
      type:    :string,
      default: 'docs'

    option :object,
      type:     SleepingKingStudios::Docs::Data::Base,
      required: true

    option :version, type: :string

    output '%<collection_path>s/%<object_path>s.yml',
      key:      :data,
      template: DATA_TEMPLATE

    # @return [Hash] parameters used to resolve output file paths and contents.
    def parameters
      super.merge(
        collection_path:,
        data_contents:,
        object_path:,
        version_string:
      )
    end

    private

    def collection
      @collection ||= tools.string_tools.pluralize(data_type)
    end

    def collection_path
      if version
        File.join(docs_path, "_#{collection}", "version--#{version}")
      else
        File.join(docs_path, "_#{collection}")
      end
    end

    def data_contents
      YAML.safe_dump(
        object.as_json.merge('version' => version_string)
      )
    end

    def data_type
      @data_type ||=
        object
        .class
        .name
        .split('::')
        .last
        .sub(/Object\z/, '')
        .then { |str| tools.string_tools.underscore(str) }
        .then { |str| str == 'root' ? 'namespace' : str }
    end

    def object_path = object.data_path

    def version_string
      return options[:version] if options[:version]

      '*'
    end
  end
end
