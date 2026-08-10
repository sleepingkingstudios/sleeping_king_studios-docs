# frozen_string_literal: true

require 'sleeping_king_studios/docs/commands'

module SleepingKingStudios::Docs::Commands
  # Namespace for installation commands, which set up an application with docs.
  module Installation
    autoload :InstallJekyll,
      'sleeping_king_studios/docs/commands/installation/install_jekyll'
  end
end
