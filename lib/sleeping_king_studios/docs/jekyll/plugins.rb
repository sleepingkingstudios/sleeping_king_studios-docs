# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll'

module SleepingKingStudios::Docs::Jekyll
  # Plugins for extending Jekyll functionality.
  module Plugins
    autoload :Liquid,   'sleeping_king_studios/docs/jekyll/plugins/liquid'
    autoload :Required, 'sleeping_king_studios/docs/jekyll/plugins/required'
  end
end
