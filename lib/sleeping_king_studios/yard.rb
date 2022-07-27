# frozen_string_literal: true

# Hic iacet Arthurus, rex quondam, rexque futurus.
module SleepingKingStudios
  # Tooling for working with YARD documentation.
  module Yard
    class << self
      # @return [String] The current version of the gem.
      def version
        VERSION
      end
    end

    autoload :Commands,      'sleeping_king_studios/yard/commands'
    autoload :Data,          'sleeping_king_studios/yard/data'
    autoload :Registry,      'sleeping_king_studios/yard/registry'
    autoload :RegistryQuery, 'sleeping_king_studios/yard/registry_query'
  end
end
