# frozen_string_literal: true

# This module is out of this world.
module Space
  class << self
    attr_reader :gravity

    attr_writer :secret_key

    attr_accessor :sandbox_mode
  end
end
