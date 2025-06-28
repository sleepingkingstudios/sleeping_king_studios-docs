# frozen_string_literal: true

require 'sleeping_king_studios/docs'

module SleepingKingStudios::Docs
  # Namespace for working with Jekyll-specific functionality.
  module Jekyll
    autoload :Plugins, 'sleeping_king_studios/docs/jekyll/plugins'
  end
end
