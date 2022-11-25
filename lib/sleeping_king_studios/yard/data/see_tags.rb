# frozen_string_literal: true

require 'sleeping_king_studios/yard/data'

module SleepingKingStudios::Yard::Data
  # Namespace for objects representing YARD @see tags.
  module SeeTags
    autoload :Base,
      'sleeping_king_studios/yard/data/see_tags/base'
    autoload :LinkTag,
      'sleeping_king_studios/yard/data/see_tags/link_tag'
    autoload :TextTag,
      'sleeping_king_studios/yard/data/see_tags/text_tag'
  end
end
