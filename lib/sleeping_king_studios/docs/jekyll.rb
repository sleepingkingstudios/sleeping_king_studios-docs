# frozen_string_literal: true

require 'sleeping_king_studios/docs'

module SleepingKingStudios::Docs
  # Namespace for working with Jekyll-specific functionality.
  module Jekyll
    autoload :Commands,   'sleeping_king_studios/docs/jekyll/commands'
    autoload :Generators, 'sleeping_king_studios/docs/jekyll/generators'
    autoload :Plugins,    'sleeping_king_studios/docs/jekyll/plugins'

    # @return [Array<Class>] the default commands for generating documentation
    #   for a Jekyll site.
    def self.commands
      [
        SleepingKingStudios::Docs::Jekyll::Commands::Clobber,
        SleepingKingStudios::Docs::Jekyll::Commands::Check,
        SleepingKingStudios::Docs::Jekyll::Commands::DocumentVersion,
        SleepingKingStudios::Docs::Jekyll::Commands::Generate,
        SleepingKingStudios::Docs::Jekyll::Commands::Update
      ]
    end

    # @return [Array<Class>] the default commands for installing a Jekyll
    #   documentation site.
    def self.install_commands
      [
        SleepingKingStudios::Docs::Jekyll::Commands::BackfillVersions,
        SleepingKingStudios::Docs::Jekyll::Commands::Install,
        SleepingKingStudios::Docs::Jekyll::Commands::InstallTemplates,
        SleepingKingStudios::Docs::Jekyll::Commands::InstallWorkflow
      ]
    end
  end
end
