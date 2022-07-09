# frozen_string_literal: true

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
module Space
  include Dimensions
  include HigherDimensions
end
