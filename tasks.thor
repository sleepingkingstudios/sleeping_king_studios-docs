# frozen_string_literal: true

load 'sleeping_king_studios/docs/tasks.rb'

require 'cuprum/cli'
require 'sleeping_king_studios/docs/jekyll'

Cuprum::Cli.initializer.call

require 'cuprum/cli/integrations/thor/registry'

registry = Cuprum::Cli::Integrations::Thor::Registry.new

# CI Commands
registry.register Cuprum::Cli::Commands::Ci::RSpecCommand
registry.register Cuprum::Cli::Commands::Ci::RSpecEachCommand

# File Commands
registry.register Cuprum::Cli::Commands::File::NewCommand

# Docs Commands
registry.register SleepingKingStudios::Docs::Jekyll::Commands::InstallWorkflow
