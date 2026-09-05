# frozen_string_literal: true

require 'plumbum'
require 'yard'

require 'sleeping_king_studios/docs/yard'

module SleepingKingStudios::Docs::Yard
  Registry = ::Data.define(:items)

  # Dependency injection provider wrapping the YARD registry.
  class Registry < ::Data
    include Enumerable

    # @return [SleepingKingStudios::Docs::Yard::Registry] a new registry
    #   instance wrapping the current YARD state.
    def self.build
      new(items: [::YARD::Registry.root, *::YARD::Registry.to_a])
    end

    # Clears the cached registry, if any.
    #
    # @todo Remove this.
    def self.clear
      @instance = nil
    end

    # Caches and returns the contents of the YARD registry.
    #
    # @return [Array] the cached registry.
    #
    # @todo Remove this.
    def self.instance
      @instance ||= [::YARD::Registry.root, *::YARD::Registry.to_a]
    end

    # Provides an injectable instance of the repository wrapper.
    #
    # @return [Plumbum::Provider<SleepingKingStudios::Docs::Registry>] the
    #   registry provider.
    def self.provider
      @provider ||= Plumbum::OneProvider.new(:registry, write_once: true)
    end

    # @param items [Array<YARD::CodeObjects::Base>] the defined YARD objects.
    def initialize(items: [])
      super
    end

    # @return [Array<YARD::CodeObjects::Base>] the defined YARD objects.
    alias to_a items

    # @overload each
    #   @return [Enumerator] an enumerator that iterates over the registry
    #     items.
    #
    # @overload each(&block)
    #   @yield [YARD::CodeObjects::Base] each item in the registry.
    def each(&)
      block_given? ? items.each(&) : enum_for(:each)
    end
  end

  class Registry
    EMPTY = new
  end
end
