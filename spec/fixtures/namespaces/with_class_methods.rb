# frozen_string_literal: true

class << self
  def calculate_isp(engine); end

  def plot_trajectory; end
  alias calculate_trajectory plot_trajectory

  private

  def solve_three_body_problem; end
end
