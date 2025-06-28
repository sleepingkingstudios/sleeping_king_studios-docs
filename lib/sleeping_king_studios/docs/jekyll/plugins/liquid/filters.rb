# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/plugins/liquid'

module SleepingKingStudios::Docs::Jekyll::Plugins::Liquid
  # Filters for extending Liquid template functionality.
  module Filters
    autoload :AnchorizeSlug,
      'sleeping_king_studios/docs/jekyll/plugins/liquid/filters/anchorize_slug'
  end
end
