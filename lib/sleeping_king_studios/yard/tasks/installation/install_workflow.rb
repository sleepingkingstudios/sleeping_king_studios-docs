# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/installation/install_workflow'
require 'sleeping_king_studios/yard/tasks/base'
require 'sleeping_king_studios/yard/tasks/installation'

module SleepingKingStudios::Yard::Tasks::Installation
  # CLI task for installing the GitHub pages CI workflow.
  class InstallWorkflow < SleepingKingStudios::Yard::Tasks::Base
    namespace 'docs:install'

    desc 'workflow', 'Installs the GitHub pages CI workflow'
    option 'dry_run',
      type:    :boolean,
      default: false,
      desc:    'If true, does not make any changes to the filesystem'
    option 'force',
      type:    :boolean,
      default: false,
      desc:    'If true, overwrites existing template files'
    option 'root_path',
      type:     :string,
      optional: true,
      desc:     'The root path for the library'
    option 'verbose',
      type:    :boolean,
      default: true,
      desc:    'if true, prints status messages to STDOUT'
    # Installs the GitHub pages CI workflow.
    def workflow
      SleepingKingStudios::Yard::Commands::Installation::InstallWorkflow
        .new(**constructor_options)
        .call(**command_options)
    end

    private

    def command_options
      return {} unless options.key?('root_path')

      { root_path: options['root_path'] }
    end

    def constructor_options
      %w[dry_run force verbose]
        .reduce({}) do |hsh, key|
          next hsh unless options.key?(key)

          hsh.merge(key.intern => options[key])
        end
    end
  end
end
