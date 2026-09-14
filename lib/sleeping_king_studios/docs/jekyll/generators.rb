# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll'

module SleepingKingStudios::Docs::Jekyll
  # Namespace for data generators, which write docs to the filesystem.
  module Generators
    autoload :DataGenerator,
      'sleeping_king_studios/docs/jekyll/generators/data_generator'
  end
end
