# frozen_string_literal: true

require 'sleeping_king_studios/yard'

module SleepingKingStudios::Yard
  # Namespace for data objects, which represent documented code.
  module Data
    autoload :NamespaceObject,
      'sleeping_king_studios/yard/data/namespace_object'
    autoload :SeeTag,
      'sleeping_king_studios/yard/data/see_tag'
  end
end
