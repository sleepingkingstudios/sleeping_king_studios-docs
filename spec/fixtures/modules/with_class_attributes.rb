# frozen_string_literal: true

# This module is out of this world.
module Space
  class << self
    attr_reader :gravity

    attr_writer :secret_key
    alias signing_key secret_key

    attr_accessor :sandbox_mode

    private

    attr_reader :curvature
  end
end
