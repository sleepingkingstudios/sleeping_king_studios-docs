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

  attr_accessor :sandbox_mode

  def calculate_isp(engine); end

  def plot_trajectory; end

  private

  attr_reader :curvature

  def solve_three_body_problem; end
end

attr_reader :base_mana

# @private
attr_reader :chiaroscuro

attr_writer :secret_formula

attr_accessor :magic_enabled

def convert_mana; end

# @private
def invoke_pact; end

def summon_dark_lord(name:); end

private

attr_reader :thaumaturgy

def generate_prophesy; end
