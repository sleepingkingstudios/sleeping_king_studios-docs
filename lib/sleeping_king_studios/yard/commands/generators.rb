# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands'

module SleepingKingStudios::Yard::Commands
  # Namespace for generator commands, which write docs to the filesystem.
  module Generators
    autoload :Base,
      'sleeping_king_studios/yard/commands/generators/base'
    autoload :DataGenerator,
      'sleeping_king_studios/yard/commands/generators/data_generator'
    autoload :ModuleGenerator,
      'sleeping_king_studios/yard/commands/generators/module_generator'
  end
end
