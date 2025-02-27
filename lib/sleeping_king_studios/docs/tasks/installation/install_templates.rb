# frozen_string_literal: true

require 'sleeping_king_studios/docs/commands/installation/install_templates'
require 'sleeping_king_studios/docs/tasks/base'
require 'sleeping_king_studios/docs/tasks/installation'

module SleepingKingStudios::Docs::Tasks::Installation
  # CLI task for installing Jekyll templates for a library.
  class InstallTemplates < SleepingKingStudios::Docs::Tasks::Base
    namespace 'docs:install'

    desc 'templates', 'Installs or updates the Jekyll templates'
    option 'docs_path',
      desc:    'The relative path to the docs folder',
      default: './docs'
    option 'dry_run',
      type:    :boolean,
      default: false,
      desc:    'If true, does not make any changes to the filesystem'
    option 'force',
      type:    :boolean,
      default: false,
      desc:    'If true, overwrites existing template files'
    option 'verbose',
      type:    :boolean,
      default: true,
      desc:    'if true, prints status messages to STDOUT'
    # Installs or updates the Jekyll templates
    def templates
      SleepingKingStudios::Docs::Commands::Installation::InstallTemplates
        .new(
          dry_run: options['dry_run'],
          force:   options['force'],
          verbose: options['verbose']
        )
        .call(docs_path: options['docs_path'])
    end
  end
end
