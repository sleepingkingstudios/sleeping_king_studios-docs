# frozen_string_literal: true

require 'sleeping_king_studios/yard'

module SleepingKingStudios::Yard
  # Namespace for data objects, which represent documented code.
  module Data
    autoload :Base,
      'sleeping_king_studios/yard/data/base'
    autoload :ConstantObject,
      'sleeping_king_studios/yard/data/constant_object'
    autoload :Metadata,
      'sleeping_king_studios/yard/data/metadata'
    autoload :ModuleObject,
      'sleeping_king_studios/yard/data/module_object'
    autoload :NamespaceObject,
      'sleeping_king_studios/yard/data/namespace_object'
    autoload :SeeTag,
      'sleeping_king_studios/yard/data/see_tag'
  end
end
