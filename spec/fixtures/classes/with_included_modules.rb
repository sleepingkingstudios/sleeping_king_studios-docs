# frozen_string_literal: true

module Measurement
  attr_accessor :depth,
    :height,
    :width

  private

  attr_accessor :chirality
end

module Dimensions
  include Measurement

  module HigherDimensions; end

  FURLONG = '660 feet'
  private_constant :FURLONG

  LENGTH = '1 meter'

  def cardinality; end
end

# This class is out of this world.
class Rocketry
  include Comparable
  include Dimensions
  include Dimensions::HigherDimensions
end
