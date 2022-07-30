# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands'

module SleepingKingStudios::Yard::Commands
  # Namespace for generator commands, which write docs to the filesystem.
  module Generators
    autoload :Base,
      'sleeping_king_studios/yard/commands/generators/base'
  end
end
