# frozen_string_literal: true

class Engineering
  class << self
    attr_accessor :blueprints

    def design; end
  end
end

module Physics
  class RocketScience < Engineering
    ANTIGRAVITY = false
    private_constant :ANTIGRAVITY

    MODEL = 'standard'

    attr_accessor :difficulty

    def project_orion; end
  end
end

# This class is out of this world.
class Rocketry < Physics::RocketScience; end
