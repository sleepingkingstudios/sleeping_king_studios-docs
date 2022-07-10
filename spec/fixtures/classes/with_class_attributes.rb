# frozen_string_literal: true

# This class is out of this world.
class Rocketry
  class << self
    attr_reader :gravity

    attr_writer :secret_key

    attr_accessor :sandbox_mode
  end
end
