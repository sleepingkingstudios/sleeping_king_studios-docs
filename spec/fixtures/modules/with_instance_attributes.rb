# frozen_string_literal: true

# This module is out of this world.
module Space
  attr_reader :base_mana

  # @private
  attr_reader :chiaroscuro
  alias_method :black_and_white, :chiaroscuro # rubocop:disable Style/Alias

  attr_writer :secret_formula

  attr_accessor :magic_enabled

  private

  attr_reader :thaumaturgy
end
