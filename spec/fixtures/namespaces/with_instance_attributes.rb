# frozen_string_literal: true

attr_reader :base_mana

# @private
attr_reader :chiaroscuro
alias_method :black_and_white, :chiaroscuro # rubocop:disable Style/Alias

attr_writer :secret_formula

attr_accessor :magic_enabled

private # rubocop:disable Lint/UselessAccessModifier

attr_reader :thaumaturgy
