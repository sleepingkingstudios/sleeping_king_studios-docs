# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll'

module SleepingKingStudios::Docs::Jekyll
  # Namespace for commands which install the Jekyll application.
  module Commands
    autoload :Install,
      'sleeping_king_studios/docs/jekyll/commands/install'
    autoload :InstallTemplates,
      'sleeping_king_studios/docs/jekyll/commands/install_templates'
    autoload :InstallWorkflow,
      'sleeping_king_studios/docs/jekyll/commands/install_workflow'
    autoload :Reference,
      'sleeping_king_studios/docs/jekyll/commands/reference'

    # Path to the template files for installing Jekyll.
    def self.templates_path # rubocop:disable Metrics/MethodLength
      @templates_path ||=
        File
        .join(
          SleepingKingStudios::Docs.gem_path,
          'lib',
          'sleeping_king_studios',
          'docs',
          'jekyll',
          'templates'
        )
        .freeze
    end
  end
end
