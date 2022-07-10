# frozen_string_literal: true

module Atmosphere
  def dew_point; end
end

module Revenge; end

module WeatherEffects
  include Atmosphere

  attr_accessor :pressure

  def temperature
    'cold'
  end
end

module Measurement
  attr_accessor :depth,
    :height,
    :width
end

module Dimensions
  include Measurement

  def cardinality; end
end

module HigherDimensions; end

# This module is out of this world.
#
# This object has a full description. It is comprised of a short description,
# followed by a multiline explanation, a list, and an essay cliche.
#
# - This is a description item.
# - This is another description item.
#
# In conclusion, space is a land of contrasts.
#
# @example Named Example
#   # This is a named example.
#
# @note This is a note.
#
# @see https://foo.
#
# @todo Remove the plutonium.
module Space
  extend Revenge
  extend WeatherEffects
  include Dimensions
  include HigherDimensions

  ELDRITCH = 'Unearthly, supernatural, eerie.'

  SQUAMOUS = 'Covered, made of, or resembling scales.'

  class FuelTank; end

  class Part; end

  class Rocket; end

  module Alchemy; end

  module Clockwork; end

  module ShadowMagic; end

  class << self
    attr_reader :gravity

    attr_writer :secret_key

    attr_accessor :sandbox_mode

    def calculate_isp(engine); end

    def plot_trajectory; end
  end

  attr_reader :base_mana

  attr_writer :secret_formula

  attr_accessor :magic_enabled

  def convert_mana; end

  def summon_dark_lord(name:); end
end
