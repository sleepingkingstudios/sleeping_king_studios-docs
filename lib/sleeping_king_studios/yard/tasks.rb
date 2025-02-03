# frozen_string_literal: true

require 'sleeping_king_studios/yard'

module SleepingKingStudios::Yard
  # Namespace for CLI tasks, powered by Thor.
  module Tasks; end
end

require 'sleeping_king_studios/yard/tasks/generate'
require 'sleeping_king_studios/yard/tasks/installation/install_jekyll'
require 'sleeping_king_studios/yard/tasks/installation/install_templates'
require 'sleeping_king_studios/yard/tasks/installation/install_workflow'
require 'sleeping_king_studios/yard/tasks/update'
