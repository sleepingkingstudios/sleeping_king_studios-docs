# frozen_string_literal: true

require 'fileutils'

require 'erubi'

require 'sleeping_king_studios/docs/commands/installation'
require 'sleeping_king_studios/docs/commands/installation/install_templates'

module SleepingKingStudios::Docs::Commands::Installation
  # Installs the Jekyll application.
  class InstallJekyll < Cuprum::Command # rubocop:disable Metrics/ClassLength
    # @overload initialize(**options)
    #   @param options [Hash] additional options for the command.
    #
    #   @option options description [String] a short description of the
    #     documented library.
    #   @option options dry_run [Boolean] if true, does not apply filesystem
    #     changes. Defaults to false.
    #   @option options name [String] the name of the documented library.
    #   @option options repository [String] the URL of the library repository.
    #   @option options verbose [Boolean] if true, prints updates to STDOUT.
    #     Defaults to true.
    def initialize(error_stream: $stderr, output_stream: $stdout, **options)
      super()

      @error_stream  = error_stream
      @output_stream = output_stream
      @options       = options
    end

    # @return [String] a short description of the documented library.
    def description
      @options.fetch(:description, 'A Ruby library.')
    end

    # @return [Boolean] if true, does not apply filesystem changes.
    def dry_run?
      @options.fetch(:dry_run, false)
    end

    # @return [String] the name of the documented library.
    def name
      @options.fetch(:name, 'Library Name')
    end

    # @return [String] the URL of the library repository.
    def repository
      @options.fetch(:repository, 'www.example.com')
    end

    # @return [Boolean] if true, prints updates to STDOUT.
    def verbose?
      @options.fetch(:verbose, true)
    end

    private

    attr_reader :docs_path

    attr_reader :error_stream

    attr_reader :output_stream

    attr_reader :project_path

    def create_configuration
      file_path = File.join(docs_path, '_config.yml')

      return if File.exist?(file_path)

      output '  - Generating Jekyll configuration'

      return if dry_run?

      File.write(
        file_path,
        evaluate_template(File.join(templates_path, 'config.yml.erb'))
      )
    end

    def create_directory
      return if Dir.exist?(docs_path)

      output "  - Creating Jekyll directory at #{docs_path}"

      return if dry_run?

      FileUtils.mkdir_p docs_path
    end

    def create_index_page
      file_path = File.join(docs_path, 'index.md')

      return if File.exist?(file_path)

      output '  - Generating index page'

      return if dry_run?

      File.write(
        file_path,
        evaluate_template(File.join(templates_path, 'pages', 'index.md.erb'))
      )
    end

    def create_pages
      step { create_index_page }
      step { create_reference_page }
      step { create_versions_page }
    end

    def create_reference_page # rubocop:disable Metrics/MethodLength
      dir_path = File.join(docs_path, 'reference')

      FileUtils.mkdir_p(dir_path) unless dry_run?

      file_path = File.join(dir_path, 'index.md')

      return if File.exist?(file_path)

      output '  - Generating reference page'

      return if dry_run?

      File.write(
        file_path,
        evaluate_template(
          File.join(templates_path, 'pages', 'reference.md.erb')
        )
      )
    end

    def create_versions_page # rubocop:disable Metrics/MethodLength
      dir_path = File.join(docs_path, 'versions')

      FileUtils.mkdir_p(dir_path) unless dry_run?

      file_path = File.join(dir_path, 'index.md')

      return if File.exist?(file_path)

      output '  - Generating versions page'

      return if dry_run?

      File.write(
        file_path,
        evaluate_template(
          File.join(templates_path, 'pages', 'versions.md.erb')
        )
      )
    end

    def evaluate_template(template_path)
      template = File.read(template_path)
      engine   = Erubi::Engine.new(template).src

      eval(engine, local_binding) # rubocop:disable Security/Eval
    end

    def install_templates
      includes_path = File.join(docs_path, '_includes')

      FileUtils.mkdir_p(includes_path) unless dry_run?

      output '  - Installing Jekyll templates'

      file_path = File.join(includes_path, 'breadcrumbs.md')

      unless File.exist?(file_path)
        template_path = File.join(templates_path, 'includes', 'breadcrumbs.md')

        File.write(file_path, File.read(template_path)) unless dry_run?
      end

      install_reference_templates
    end

    def install_reference_templates
      SleepingKingStudios::Docs::Commands::Installation::InstallTemplates
        .new(
          dry_run:         dry_run?,
          force:           false,
          ignore_existing: true,
          verbose:         false
        )
        .call(docs_path:)
    end

    def jekyll_cache_path
      File.join(docs_path, '.jekyll-cache').sub(/\A\./, '')
    end

    def jekyll_site_path
      File.join(docs_path, '_site').sub(/\A\./, '')
    end

    def local_binding
      return @local_binding if @local_binding

      description = self.description
      name        = self.name
      repository  = self.repository

      @local_binding = binding
    end

    def output(string)
      return unless verbose?

      output_stream.puts(string)
    end

    def process(docs_path:, project_path: Dir.pwd)
      @docs_path    = docs_path
      @project_path = project_path

      output "Installing SleepingKingStudios::YARD to #{docs_path}..."

      step { update_gitignore }
      step { create_directory }
      step { create_configuration }
      step { create_pages }
      step { install_templates }

      output 'Done!'
    end

    def templates_path
      @templates_path ||=
        File.join(
          SleepingKingStudios::Yard.gem_path,
          'lib',
          'sleeping_king_studios',
          'yard',
          'templates'
        )
    end

    def update_gitignore
      file_path = File.join(project_path, '.gitignore')

      FileUtils.touch(file_path) unless dry_run?

      original_contents = File.read(file_path)
      updated_contents  = update_gitignore_contents(original_contents:)

      return if updated_contents == original_contents

      output '  - Updating .gitignore'

      File.write(file_path, updated_contents) unless dry_run?
    end

    def update_gitignore_contents(original_contents:) # rubocop:disable Metrics/MethodLength
      updated = original_contents
      ignored = original_contents.each_line.map(&:strip)

      unless ignored.include?(jekyll_cache_path)
        updated += "\n" unless updated.empty? || updated.end_with?("\n")
        updated += "#{jekyll_cache_path}\n"
      end

      unless ignored.include?(jekyll_site_path)
        updated += "\n" unless updated.end_with?("\n")
        updated += "#{jekyll_site_path}\n"
      end

      updated
    end
  end
end
