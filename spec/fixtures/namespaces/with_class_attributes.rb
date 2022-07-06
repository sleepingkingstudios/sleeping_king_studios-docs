# frozen_string_literal: true

class << self
  attr_reader :gravity

  attr_writer :secret_key

  attr_accessor :sandbox_mode
end
