# frozen_string_literal: true

module Measurement
  attr_accessor :depth,
    :height,
    :width
end

module Dimensions
  include Measurement

  module HigherDimensions; end

  def cardinality; end
end

# This module is out of this world.
module Space
  include Dimensions
  include Dimensions::HigherDimensions
end
