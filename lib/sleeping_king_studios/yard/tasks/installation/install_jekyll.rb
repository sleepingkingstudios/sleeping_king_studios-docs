# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/installation/install_jekyll'
require 'sleeping_king_studios/yard/tasks/base'
require 'sleeping_king_studios/yard/tasks/installation'

module SleepingKingStudios::Yard::Tasks::Installation
  # CLI task for installing the Jekyll application.
  class InstallJekyll < SleepingKingStudios::Yard::Tasks::Base
    namespace 'docs'

    desc 'install', 'Install the Jekyll application'
    option 'description',
      type:     :string,
      optional: true,
      desc:     'A short description of the documented library.'
    option 'docs_path',
      desc:    'The relative path to the docs folder',
      default: './docs'
    option 'dry_run',
      type:    :boolean,
      default: false,
      desc:    'If true, does not make any changes to the filesystem'
    option 'name',
      type:     :string,
      optional: true,
      desc:     'The name of the documented library.'
    option 'repository',
      type:     :string,
      optional: true,
      desc:     'The URL of the library repository.'
    option 'root_path',
      type:     :string,
      optional: true,
      desc:     'The root path for the library'
    option 'verbose',
      type:    :boolean,
      default: true,
      desc:    'if true, prints status messages to STDOUT'
    # Install the Jekyll application
    def install
      SleepingKingStudios::Yard::Commands::Installation::InstallJekyll
        .new(**constructor_options)
        .call(**command_options)
    end

    private

    def command_options
      %w[docs_path root_path]
        .reduce({}) do |hsh, key|
          next hsh unless options.key?(key)

          hsh.merge(key.intern => options[key])
        end
    end

    def constructor_options
      %w[description dry_run name repository verbose]
        .reduce({}) do |hsh, key|
          next hsh unless options.key?(key)

          hsh.merge(key.intern => options[key])
        end
    end
  end
end
