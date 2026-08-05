# frozen_string_literal: true

require 'cuprum/cli'

require 'sleeping_king_studios/docs/jekyll/commands'

module SleepingKingStudios::Docs::Jekyll::Commands
  # Command for installing a Github workflow to deploy the docs to Pages.
  class InstallWorkflow < Cuprum::Cli::Command
    dependency :file_system
    dependency :standard_io

    include Cuprum::Cli::Options::Quiet
    include Cuprum::Cli::Options::Verbose

    # Generator for writing the workflow template.
    class Generator < Cuprum::Cli::Files::Generator
      output '%<file_path>s',
        template: File.join(
          SleepingKingStudios::Docs.gem_path,
          'lib',
          'sleeping_king_studios',
          'docs',
          'templates',
          'deploy-pages.yml.erb'
        )

      option :ruby_version
    end

    private

    full_name 'docs:jekyll:install_workflow'

    description \
      'Installs a GitHub workflow to deploy the Jekyll application to Github ' \
      'Pages'

    option :dry_run, type: :boolean, default: false

    option :file_path,
      type:    :string,
      default: '.github/workflows/deploy-pages.yml'

    option :ruby_version,
      default: -> { RUBY_VERSION.split('.')[..1].join('.') }

    def process
      Generator
        .new(
          file_path,
          file_system:,
          standard_io:,
          **options.except(:file_path)
        )
        .call
    end
  end
end
