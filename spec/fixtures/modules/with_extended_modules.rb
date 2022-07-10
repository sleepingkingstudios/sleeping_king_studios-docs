# frozen_string_literal: true

module Atmosphere
  def dew_point; end
end

module Revenge; end

module Phenomena
  module WeatherEffects
    include Atmosphere

    attr_accessor :pressure

    def temperature
      'cold'
    end
  end
end

# This module is out of this world.
module Space
  extend Revenge
  extend Phenomena::WeatherEffects
end
