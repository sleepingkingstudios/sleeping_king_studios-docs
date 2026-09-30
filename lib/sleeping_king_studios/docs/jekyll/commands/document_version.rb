# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/commands'

module SleepingKingStudios::Docs::Jekyll::Commands
  # Generates pinned documentation for the specified project version.
  #
  # - Adds the version to the _versions collection.
  # - Generates reference documentation for the version.
  # - Copies all static documentation files to the respective versions/*
  #   subdirectory.
  class DocumentVersion < Cuprum::Cli::Command # rubocop:disable Metrics/ClassLength
    dependency :file_system
    dependency :standard_io

    include Cuprum::Cli::Dependencies::StandardIo::Helpers
    include Cuprum::Cli::Options::Quiet
    include Cuprum::Cli::Options::Verbose

    argument :version, type: :string, required: true

    option :docs_path, default: 'docs'

    option :dry_run,   type: :boolean, default: false

    full_name 'docs:jekyll:document_version'

    description 'Generates pinned documentation for the specified version'

    private

    def copy_static_file(original_path)
      relative_path = original_path.sub(%r{#{docs_path}/}, '')
      updated_path  = File.join(docs_path, 'versions', version, relative_path)

      contents       = file_system.read_file(original_path)
      metadata, text = step { extract_front_matter(contents) }
      metadata       = update_metadata(metadata:, relative_path:)
      contents       = generate_contents(metadata:, text:)

      files = step { write_static_file(contents:, updated_path:) }

      @files.concat(files)
    end

    def copy_static_files
      say "\nCopying static documentation..."
      say("\n", verbose: true)

      find_static_docs.each { |file_path| copy_static_file(file_path) }
    end

    def default_breadcrumbs_for(relative_path)
      *dir_path, _ = relative_path.split(File::SEPARATOR)

      return [] if dir_path.empty?

      dir_path
        .each
        .map do |segment, index|
          name = tools.string_tools.camelize(segment.tr('-_', ''))
          path = "#{File::SEPARATOR}#{File.join(dir_path[0..index])}"

          { 'name' => name, 'path' => path }
        end
    end

    def exclude_static_file?(file_path)
      return false if file_path == "#{docs_path}/reference/index.md"

      file_path.start_with?("#{docs_path}/_includes/") ||
        file_path.start_with?("#{docs_path}/reference") ||
        file_path.start_with?("#{docs_path}/versions")
    end

    def extract_front_matter(contents)
      return [{}, contents] unless contents.start_with?("---\n")

      match = /^---\n$/.match(contents[4..])

      return [{}, contents] unless match

      text = match.post_match
      yaml = YAML.safe_load(match.pre_match) || {}

      [yaml, text]
    end

    def generate_contents(metadata:, text:)
      "#{YAML.safe_dump(metadata)}---\n#{text}"
    end

    def generate_reference_files # rubocop:disable Metrics/MethodLength
      say "\nGenerating data and reference files:"
      say("\n", verbose: true)

      files = step do
        SleepingKingStudios::Docs::Jekyll::Commands::Generate
          .new(file_system:, standard_io:)
          .call(
            docs_path:,
            dry_run:   dry_run?,
            quiet:     quiet?,
            verbose:   verbose?,
            version:
          )
      end

      @files.concat(files)
    end

    def generate_version # rubocop:disable Metrics/MethodLength
      say "\nGenerating version file:"
      say("\n", verbose: true)

      files = step do
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
      end

      @files.concat(files)
    end

    def find_static_docs
      file_system
        .each_file("#{docs_path}/**/*.md")
        .reject { |file_path| exclude_static_file?(file_path) }
        .to_a
    end

    def process
      say "Generating pinned documentation for version #{version}"

      @files = []

      step { generate_reference_files }

      step { generate_version }

      step { copy_static_files }

      say "\nSuccess!"

      @files
    end

    def top_level_breadcrumb?(obj)
      obj.is_a?(Hash) && obj['path'] == File::SEPARATOR
    end

    def version_breadcrumbs # rubocop:disable Metrics/MethodLength
      @version_breadcrumbs ||= [
        {
          'name' => 'Documentation',
          'path' => File::SEPARATOR
        },
        {
          'name' => 'Versions',
          'path' => "#{File::SEPARATOR}versions"
        },
        {
          'name' => "Version #{version}",
          'path' => "#{File::SEPARATOR}#{File.join('versions', version)}"
        }
      ]
    end

    def update_breadcrumbs(breadcrumbs:, relative_path:)
      prefix      = "#{File::SEPARATOR}#{File.join('versions', version)}"
      breadcrumbs = breadcrumbs[1..] if top_level_breadcrumb?(breadcrumbs.first)
      breadcrumbs = breadcrumbs.map do |hsh|
        hsh.merge('path' => File.join(prefix, hsh['path']))
      end

      if breadcrumbs.empty? && relative_path == 'index.md'
        return version_breadcrumbs[...-1]
      end

      version_breadcrumbs + breadcrumbs
    end

    def update_metadata(metadata:, relative_path:)
      breadcrumbs = update_breadcrumbs(
        breadcrumbs:   metadata.fetch(
          'breadcrumbs',
          default_breadcrumbs_for(relative_path)
        ),
        relative_path:
      )

      metadata.merge('breadcrumbs' => breadcrumbs, 'version' => version)
    end

    def write_static_file(contents:, updated_path:) # rubocop:disable Metrics/MethodLength
      Cuprum::Cli::Files::Generators::BasicGenerator
        .new(
          file_system:,
          standard_io:,
          contents:,
          dry_run:     dry_run?,
          file_path:   updated_path,
          quiet:       quiet?,
          verbose:     verbose?
        )
        .call
    end
  end
end
