# frozen_string_literal: true

require 'thor'

require 'sleeping_king_studios/tools/toolbelt'

require 'sleeping_king_studios/yard'

module SleepingKingStudios::Yard
  module Tasks
    # Generic base CLI task.
    class Base < Thor
      private

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end
    end
  end
end
