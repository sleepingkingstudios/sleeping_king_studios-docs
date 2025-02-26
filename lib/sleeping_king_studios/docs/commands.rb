# frozen_string_literal: true

require 'sleeping_king_studios/docs'

module SleepingKingStudios::Docs
  # Namespace for commands, which parse and generate documentation files.
  module Commands
    autoload :Generate,     'sleeping_king_studios/docs/commands/generate'
    autoload :Generators,   'sleeping_king_studios/docs/commands/generators'
    autoload :Installation, 'sleeping_king_studios/docs/commands/installation'
    autoload :Parse,        'sleeping_king_studios/docs/commands/parse'
    autoload :WriteFile,    'sleeping_king_studios/docs/commands/write_file'
  end
end
