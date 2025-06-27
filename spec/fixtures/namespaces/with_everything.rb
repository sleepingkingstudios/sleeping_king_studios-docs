# frozen_string_literal: true

ELDRITCH = 'Unearthly, supernatural, eerie.'

# @private
INEFFABLE = 'Not to be uttered; taboo.'

SQUAMOUS = 'Covered, made of, or resembling scales.'

UNDETECTABLE = 'Cannot be seen.'
private_constant :UNDETECTABLE

# @private
class AutoStrut; end

class FuelTank; end

class Part; end

class Rocket; end

module Alchemy; end

module Clockwork; end

module ShadowMagic; end

# @private
module VoidMagic; end

class << self
  attr_reader :gravity

  attr_writer :secret_key
  alias signing_key secret_key

  attr_accessor :sandbox_mode

  def calculate_isp(engine); end

  def plot_trajectory; end
  alias calculate_trajectory plot_trajectory

  private

  attr_reader :curvature

  def solve_three_body_problem; end
end

attr_reader :base_mana

# @private
attr_reader :chiaroscuro
alias_method :black_and_white, :chiaroscuro # rubocop:disable Style/Alias

attr_writer :secret_formula

attr_accessor :magic_enabled

def convert_mana; end
alias_method :transform_mana, :convert_mana # rubocop:disable Style/Alias

# @private
def invoke_pact; end

def summon_dark_lord(name:); end

private # rubocop:disable Lint/UselessAccessModifier

attr_reader :thaumaturgy

def generate_prophesy; end
