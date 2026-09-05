# frozen_string_literal: true

require 'sleeping_king_studios/docs'

module SleepingKingStudios::Docs
  # Functionality for parsing and querying YARD documentation.
  module Yard
    autoload :Registry, 'sleeping_king_studios/docs/yard/registry'
  end
end
