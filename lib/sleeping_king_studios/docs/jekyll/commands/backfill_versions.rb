# frozen_string_literal: true

require 'yaml'

require 'cuprum/cli/files/generators'

require 'sleeping_king_studios/docs/jekyll/commands'

module SleepingKingStudios::Docs::Jekyll::Commands
  # Helper command to populate the versions collection with past version data.
  class BackfillVersions < Cuprum::Cli::Command # rubocop:disable Metrics/ClassLength
    include Cuprum::Cli::Dependencies::StandardIo::Helpers
    include Cuprum::Cli::Options::Quiet
    include Cuprum::Cli::Options::Verbose

    MAJOR_VERSION = /\A\d+\z/
    private_constant :MAJOR_VERSION

    MAJOR_MINOR_VERSION = /\A\d+\.\d+\z/
    private_constant :MAJOR_MINOR_VERSION

    MAJOR_MINOR_PATCH_VERSION = /\A\d+\.\d+\.\d+(\.)?/
    private_constant :MAJOR_MINOR_PATCH_VERSION

    NEXT_STEPS_MESSAGE = <<~OUTPUT
      Next Steps

        Update _config.yml:

        - In %<docs_path>s/_config.yml, add `versions: { output: false }` to `collections`.
        - In %<docs_path>s/_config.yml, remove `project_metadata.versions`.

        Update versions/index.md:

        - In %<docs_path>s/versions/index.md, replace the versions loop with the following:

        ```ruby
        {%% assign versions = site.versions | sort: "sortable" | map: "version" | reverse %%}
        {%% for version in versions %%}
        - [Version {{ version }}]({{site.baseurl}}/versions/{{version}})
        {%%- endfor %%}
        ```
    OUTPUT
    private_constant :NEXT_STEPS_MESSAGE

    full_name 'docs:jekyll:backfill_versions'

    description 'Backfills the versions collection'

    dependency :file_system
    dependency :standard_io

    option :docs_path, default: 'docs'

    option :dry_run, type: :boolean, default: false

    private

    attr_reader :files

    attr_reader :versions

    def configured_versions
      say "Checking _config.yml for existing versions...\n\n"

      data = parse_config_file&.dig('project_metadata', 'versions')

      return [] unless data.is_a?(Array)

      say "  Found versions #{data.join(', ')}\n\n"

      data.map(&:to_s)
    end

    def create_version(version) # rubocop:disable Metrics/MethodLength
      result =
        SleepingKingStudios::Docs::Jekyll::Generators::VersionGenerator
        .new(
          file_system:,
          standard_io:,
          docs_path:,
          dry_run:     dry_run?,
          quiet:       quiet?,
          verbose:     verbose?,
          version:
        )
        .call

      files.concat(result.value) if result.success?
    end

    def create_versions_directory
      dir_path = File.join(docs_path, '_versions')

      file_system.create_directory(dir_path, recursive: true) unless dry_run?

      say "Successfully generated versions collection at #{dir_path}.\n\n"
    end

    def display_message
      say "\n" unless versions.empty? || verbose?

      say format(NEXT_STEPS_MESSAGE, docs_path:)
    end

    def parse_config_file
      raw = read_config_file

      return unless raw

      YAML.safe_load(raw)
    rescue Psych::SyntaxError => exception
      file_path = File.join(docs_path, '_config.yml')

      warn \
        "  Unable to parse config file at #{file_path} - #{exception.class}: " \
        "#{exception.message}\n\n"
    end

    def process
      @files    = []
      @versions = []

      versions.concat(configured_versions)
      versions.concat(version_directories)

      step { create_versions_directory }

      versions.compact.uniq.each do |version|
        step { create_version(version) }
      end

      display_message

      files
    end

    def read_config_file
      file_path = File.join(docs_path, '_config.yml')

      file_system.read_file(file_path)
    rescue Cuprum::Cli::Dependencies::FileSystem::FileError => exception
      warn \
        "  Unable to read config file - #{exception.class}: " \
        "#{exception.message}\n\n"
    end

    def version_directories
      say "Checking versions directory for existing versions...\n\n"

      matching =
        file_system
        .each_file("#{docs_path}/versions/*")
        .select { |file_name| file_system.directory?(file_name) }
        .map { |file_name| File.basename(file_name) }
        .select { |segment| version_string?(segment) }

      say "  Found versions #{matching.join(', ')}\n\n" unless matching.empty?

      matching
    end

    def version_string?(value)
      MAJOR_VERSION.match?(value) ||
        MAJOR_MINOR_VERSION.match?(value) ||
        MAJOR_MINOR_PATCH_VERSION.match?(value)
    end
  end
end
