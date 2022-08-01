# frozen_string_literal: true

require 'sleeping_king_studios/yard'

module SleepingKingStudios::Yard
  # Namespace for commands, which parse and generate documentation files.
  module Commands
    autoload :Generate,   'sleeping_king_studios/yard/commands/generate'
    autoload :Generators, 'sleeping_king_studios/yard/commands/generators'
    autoload :Parse,      'sleeping_king_studios/yard/commands/parse'
    autoload :WriteFile,  'sleeping_king_studios/yard/commands/write_file'
  end
end
