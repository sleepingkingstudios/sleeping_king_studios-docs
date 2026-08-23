# frozen_string_literal: true

require 'sleeping_king_studios/docs'

module SleepingKingStudios::Docs
  # Namespace for working with YARD-specific functionality.
  module Yard
    autoload :Parse, 'sleeping_king_studios/docs/yard/parse'
  end
end
