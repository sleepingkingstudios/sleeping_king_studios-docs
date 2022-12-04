# frozen_string_literal: true

class << self
  attr_reader :gravity

  attr_writer :secret_key
  alias signing_key secret_key

  attr_accessor :sandbox_mode

  private

  attr_reader :curvature
end
