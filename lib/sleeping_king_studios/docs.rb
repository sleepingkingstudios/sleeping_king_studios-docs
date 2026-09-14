# frozen_string_literal: true

require 'cuprum/cli'
require 'sleeping_king_studios/tools'

# Hic iacet Arthurus, rex quondam, rexque futurus.
module SleepingKingStudios
  # Tooling for working with YARD documentation.
  module Docs
    autoload :Data,   'sleeping_king_studios/docs/data'
    autoload :Errors, 'sleeping_king_studios/docs/errors'
    autoload :Jekyll, 'sleeping_king_studios/docs/jekyll'
    autoload :Yard,   'sleeping_king_studios/docs/yard'

    @initializer = SleepingKingStudios::Tools::Toolbox::Initializer.new do
      Cuprum::Cli.initializer.call

      SleepingKingStudios::Tools.initializer.call
    end

    # @return [String] the absolute path to the gem directory.
    def self.gem_path
      pattern = /#{File.join('', 'lib', 'sleeping_king_studios', '')}?\z/

      __dir__.sub(pattern, '')
    end

    # @return [SleepingKingStudios::Tools::Toolbox::Initializer] the initializer
    #   for the module.
    def self.initializer
      @initializer
    end

    # @return [String] The current version of the gem.
    def self.version
      VERSION
    end
  end
end
