# frozen_string_literal: true

require 'yard'

require 'sleeping_king_studios/docs'

module SleepingKingStudios::Docs
  # Dependency injection provider wrapping the YARD registry.
  module Registry
    # Clears the cached registry, if any.
    def self.clear
      @instance = nil
    end

    # Caches and returns the contents of the YARD registry.
    #
    # @return [Array] the cached registry.
    def self.instance
      @instance ||= [::YARD::Registry.root, *::YARD::Registry.to_a]
    end
  end
end
