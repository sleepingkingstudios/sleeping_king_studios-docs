# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands'

module SleepingKingStudios::Docs::Commands
  # Namespace for generator commands, which write docs to the filesystem.
  module Generators
    autoload :Base,
      'sleeping_king_studios/docs/commands/generators/base'
    autoload :DataGenerator,
      'sleeping_king_studios/docs/commands/generators/data_generator'
    autoload :ReferenceGenerator,
      'sleeping_king_studios/docs/commands/generators/reference_generator'
  end
end
