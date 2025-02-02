# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands'

module SleepingKingStudios::Yard::Commands
  # Namespace for installation commands, which set up an application with docs.
  module Installation
    autoload :InstallTemplates,
      'sleeping_king_studios/yard/commands/installation/install_templates'
  end
end
