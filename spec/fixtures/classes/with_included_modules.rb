# frozen_string_literal: true

module Measurement
  attr_accessor :depth,
    :height,
    :width
end

module Dimensions
  include Measurement

  module HigherDimensions; end

  LENGTH = '1 meter'

  def cardinality; end
end

# This class is out of this world.
class Rocketry
  include Comparable
  include Dimensions
  include Dimensions::HigherDimensions
end
