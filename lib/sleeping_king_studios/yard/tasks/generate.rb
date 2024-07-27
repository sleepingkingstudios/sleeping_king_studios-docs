# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/generate'
require 'sleeping_king_studios/yard/tasks'
require 'sleeping_king_studios/yard/tasks/base'

module SleepingKingStudios::Yard::Tasks
  # CLI task for generating documentation files.
  class Generate < SleepingKingStudios::Yard::Tasks::Base
    namespace 'docs'

    desc 'generate', 'Generates documentation files for the project'
    option 'version',
      type:    :string,
      desc:    'The code version for the generated documentation',
      default: nil
    option 'docs_path',
      desc:    'The relative path to the docs folder',
      default: './docs'
    option 'dry_run',
      type:    :boolean,
      default: false,
      desc:    'If true, does not make any changes to the filesystem'
    option 'force',
      type:    :boolean,
      default: false,
      desc:    'If true, overwrites any existing files'
    option 'verbose',
      type:    :boolean,
      default: true,
      desc:    'if true, prints status messages to STDOUT'
    def generate
      SleepingKingStudios::Yard::Commands::Generate
        .new(**tools.hash_tools.symbolize_keys(options))
        .call
    end
  end
end
