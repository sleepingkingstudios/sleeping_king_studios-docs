# frozen_string_literal: true

require 'sleeping_king_studios/yard'

module SleepingKingStudios::Yard
  # Namespace for error objects, which encapsulate command failure states.
  module Errors
    autoload :InvalidPath, 'sleeping_king_studios/yard/errors/invalid_path'
  end
end
