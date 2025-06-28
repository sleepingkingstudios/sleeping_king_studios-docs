# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/plugins/liquid/filters'

module SleepingKingStudios::Docs::Jekyll::Plugins::Liquid::Filters
  # Liquid filter for converting a reference slug to a safe HTML anchor.
  module AnchorizeSlug
    # Converts the slug to a string usable as an HTML anchor.
    #
    # Certain characters are valid Ruby identifiers but cause issues when used
    # as HTML anchors, such as equals signs, hashes, question marks, and square
    # brackets. This method replaces each with a placeholder value.
    #
    # @param slug [String] the slug to convert.
    #
    # @return [String] the converted slug.
    def anchorize_slug(slug)
      slug
        .to_s
        .gsub('=', '--equals')
        .gsub('?', '--predicate')
        .gsub('[]', '--brackets')
    end

    ::Liquid::Template.register_filter(self) if defined?(::Liquid::Template)
  end
end
