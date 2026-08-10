# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll'

module SleepingKingStudios::Docs::Jekyll
  # Namespace for commands which install the Jekyll application.
  module Commands
    autoload :InstallTemplates,
      'sleeping_king_studios/docs/jekyll/commands/install_templates'
    autoload :InstallWorkflow,
      'sleeping_king_studios/docs/jekyll/commands/install_workflow'
  end
end
