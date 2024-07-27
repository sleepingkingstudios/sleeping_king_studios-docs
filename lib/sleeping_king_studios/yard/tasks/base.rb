# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'

require 'sleeping_king_studios/yard/tasks'

module SleepingKingStudios::Yard::Tasks
  # Generic base CLI task.
  class Base < Thor
    # @private
    def self.exit_on_failure?
      true
    end

    private

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
