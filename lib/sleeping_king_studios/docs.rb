# frozen_string_literal: true

# Hic iacet Arthurus, rex quondam, rexque futurus.
module SleepingKingStudios
  # Tooling for working with YARD documentation.
  module Docs
    class << self
      # @return [String] the absolute path to the gem directory.
      def gem_path
        pattern = /#{File.join('', 'lib', 'sleeping_king_studios', '')}?\z/

        __dir__.sub(pattern, '')
      end

      # @return [String] The current version of the gem.
      def version
        VERSION
      end
    end

    autoload :Commands,      'sleeping_king_studios/yard/commands'
    autoload :Data,          'sleeping_king_studios/yard/data'
    autoload :Errors,        'sleeping_king_studios/yard/errors'
    autoload :Registry,      'sleeping_king_studios/docs/registry'
    autoload :RegistryQuery, 'sleeping_king_studios/docs/registry_query'
  end
end
