# frozen_string_literal: true

# This module is out of this world.
module Space
  class << self
    def calculate_isp(engine); end

    def plot_trajectory; end
    alias calculate_trajectory plot_trajectory

    private

    def solve_three_body_problem; end
  end
end
