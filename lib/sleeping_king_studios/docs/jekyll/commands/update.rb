# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/commands'

module SleepingKingStudios::Docs::Jekyll::Commands
  # Creates or updates reference documentation.
  class Update < SleepingKingStudios::Docs::Jekyll::Commands::Reference
    full_name 'docs:jekyll:update'

    description 'Updates reference documentation for the current version'

    private

    def clobber_files
      SleepingKingStudios::Docs::Jekyll::Commands::Clobber
        .new(file_system:, standard_io:)
        .call(**options)
    end

    def generate_files
      SleepingKingStudios::Docs::Jekyll::Commands::Generate
        .new(file_system:, standard_io:)
        .call(**options)
    end

    def process
      step { clobber_files }

      step { generate_files }
    end
  end
end
