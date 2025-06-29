# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/plugins'

module SleepingKingStudios::Docs::Jekyll::Plugins
  # Helper module for loading all required Jekyll plugins.
  module Required
    include Liquid::Filters::AnchorizeSlug
  end
end
