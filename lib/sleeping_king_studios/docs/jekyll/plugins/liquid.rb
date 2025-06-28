# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/plugins'

module SleepingKingStudios::Docs::Jekyll::Plugins
  # Plugins for extending Liquid template functionality.
  module Liquid
    autoload :Filters,
      'sleeping_king_studios/docs/jekyll/plugins/liquid/filters'
  end
end
