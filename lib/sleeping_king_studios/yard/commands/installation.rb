# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands'

module SleepingKingStudios::Yard::Commands
  # Namespace for installation commands, which set up an application with docs.
  module Installation
    autoload :InstallJekyll,
      'sleeping_king_studios/yard/commands/installation/install_jekyll'
    autoload :InstallTemplates,
      'sleeping_king_studios/yard/commands/installation/install_templates'
    autoload :InstallWorkflow,
      'sleeping_king_studios/yard/commands/installation/install_workflow'
  end
end
