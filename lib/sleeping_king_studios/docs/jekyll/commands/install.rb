# frozen_string_literal: true

require 'cuprum/cli'

require 'sleeping_king_studios/docs/jekyll/commands'

module SleepingKingStudios::Docs::Jekyll::Commands
  # Installs the Jekyll application.
  class Install < Cuprum::Cli::Command # rubocop:disable Metrics/ClassLength
    dependency :file_system
    dependency :standard_io

    include Cuprum::Cli::Dependencies::StandardIo::Helpers
    include Cuprum::Cli::Options::Quiet
    include Cuprum::Cli::Options::Verbose

    TEMPLATES_PATH = SleepingKingStudios::Docs::Jekyll::Commands.templates_path
    private_constant :TEMPLATES_PATH

    # Generator for writing the Jekyll static pages.
    class Generator < Cuprum::Cli::Files::Generator
      output '%<docs_path>s/_config.yml',
        key:      :config,
        template: File.join(TEMPLATES_PATH, 'config.yml.erb')

      output '%<docs_path>s/_layouts/page.html',
        key:      :layout,
        template: File.join(TEMPLATES_PATH, 'layouts', 'page.html.erb')

      output '%<docs_path>s/index.md',
        key:      :index,
        template: File.join(TEMPLATES_PATH, 'pages', 'index.md.erb')

      output '%<docs_path>s/reference/index.md',
        key:      :reference,
        template: File.join(TEMPLATES_PATH, 'pages', 'reference.md.erb')

      output '%<docs_path>s/versions/index.md',
        key:      :versions,
        template: File.join(TEMPLATES_PATH, 'pages', 'versions.md.erb')

      option :docs_path,           default: 'docs'

      option :project_description, default: ''

      option :project_name,        default: 'Project Name'

      option :project_repository,  default: ''
    end

    full_name 'docs:jekyll:install'

    description 'Installs the Jekyll application'

    option :docs_path, type: :string,  default: 'docs'

    option :dry_run,   type: :boolean, default: false

    option :force,     type: :boolean, default: false

    option :gemfile,   type: :boolean, default: true

    option :gitignore, type: :boolean, default: true

    option :templates, type: :boolean, default: true

    option :workflow,  type: :boolean, default: false

    private

    attr_reader :errors

    attr_reader :output_paths

    def create_directory
      return if file_system.directory?(docs_path)

      say "Generating directory #{docs_path}..."
      say("\n", verbose: true)

      file_system.create_directory(docs_path, recursive: true) unless dry_run?
    end

    def create_gemfile
      gems     = included_gems.map { |k, v| "  gem '#{k}', '#{v}'" }.join("\n")
      contents = <<~GEMFILE
        # frozen_string_literal: true

        source 'https://rubygems.org'

        group: :docs do
        #{gems}
        end
      GEMFILE

      say 'Generating Gemfile...'
      say("\n#{indent(contents, 2)}\n", verbose: true)

      file_system.write_file('Gemfile', contents) unless dry_run?
    end

    def create_gitignore
      contents = "# Ignore Jekyll site and temporary files.\n"

      ignored_paths.each { |path| contents = "#{contents}#{path}\n" }

      say 'Generating .gitignore...'
      say("\n#{indent(contents, 2)}\n", verbose: true)

      file_system.write_file('.gitignore', contents) unless dry_run?
    end

    def create_static_files # rubocop:disable Metrics/MethodLength
      static_files = step do
        Generator
          .new(
            file_system:,
            standard_io:,
            docs_path:,
            dry_run:     dry_run?,
            directories: true,
            quiet:       quiet?,
            verbose:     verbose?
          )
          .call
      end

      output_paths.concat(static_files)
    end

    def handle_file_error(file_path)
      yield

      success(file_path)
    rescue Cuprum::Cli::Dependencies::FileSystem::FileError => exception
      warn("  ! #{exception.message}")

      error = Cuprum::Cli::Files::Errors::FileNotWriteable.new(
        file_path:,
        message:   exception.message
      )
      failure(error)
    end

    def ignored_paths
      [
        "#{docs_path}/_site",
        "#{docs_path}/.sass-cache",
        "#{docs_path}/.jekyll-cache",
        "#{docs_path}/.jekyll-metadata",
        'vendor'
      ]
    end

    def included_gems
      {
        'jekyll'              => '~> 4.4',
        'kramdown-parser-gfm' => '~> 1.1',
        'webrick'             => '~> 1.8'
      }
    end

    def indent(str, count) = tools.string_tools.indent(str, count)

    def install_templates # rubocop:disable Metrics/MethodLength
      return unless templates?

      template_files = step do
        SleepingKingStudios::Docs::Jekyll::Commands::InstallTemplates
          .new(file_system:, standard_io:)
          .call(
            docs_path:,
            dry_run:   dry_run?,
            quiet:     quiet?,
            verbose:   verbose?
          )
      end

      say("\n", verbose: true)

      output_paths.concat(template_files)
    end

    def install_workflow # rubocop:disable Metrics/MethodLength
      return unless workflow?

      workflow_files = step do
        SleepingKingStudios::Docs::Jekyll::Commands::InstallWorkflow
          .new(file_system:, standard_io:)
          .call(
            dry_run: dry_run?,
            quiet:   quiet?,
            verbose: verbose?
          )
      end

      output_paths.concat(workflow_files)
    end

    def merge_gemfile # rubocop:disable Metrics/AbcSize
      contents = file_system.read_file('Gemfile')
      existing = contents.each_line.map(&:strip)
      added    = included_gems.reject { |k, _| existing.include?("gem '#{k}'") }

      return if added.empty?

      gems = added.map { |k, v| "  gem '#{k}', '#{v}'" }.join("\n")

      contents << "\n" unless contents.end_with?("\n\n")
      contents << "group :docs do\n#{gems}\nend\n"

      say 'Updating Gemfile...'
      say("\n#{indent(contents, 2)}\n", verbose: true)

      file_system.write_file('Gemfile', contents) unless dry_run?
    end

    def merge_gitignore # rubocop:disable Metrics/AbcSize
      contents = file_system.read_file('.gitignore')
      existing = contents.each_line.map(&:strip)
      added    = ignored_paths.reject { |path| existing.include?(path) }

      return if added.empty?

      contents << "\n" unless contents.end_with?("\n\n")
      contents << "# Ignore Jekyll site and temporary files.\n"

      added.each { |path| contents << path << "\n" }

      say 'Updating .gitignore...'
      say("\n#{indent(contents, 2)}\n", verbose: true)

      file_system.write_file('.gitignore', contents) unless dry_run?
    end

    def process
      @output_paths = []

      step { update_gitignore }
      step { update_gemfile }
      step { create_directory }
      step { create_static_files }
      step { install_templates }
      step { install_workflow }

      output_paths
    end

    def update_gemfile
      return unless gemfile?

      step do
        handle_file_error('Gemfile') do
          file_system.file?('Gemfile') ? merge_gemfile : create_gemfile
        end
      end

      output_paths << 'Gemfile'
    end

    def update_gitignore
      return unless gitignore?

      step do
        handle_file_error('.gitignore') do
          file_system.file?('.gitignore') ? merge_gitignore : create_gitignore
        end
      end

      output_paths << '.gitignore'
    end
  end
end
