# frozen_string_literal: true

require 'sleeping_king_studios/yard'

module SleepingKingStudios::Yard
  # Namespace for data objects, which represent documented code.
  module Data
    autoload :Base,
      'sleeping_king_studios/yard/data/base'
    autoload :ClassObject,
      'sleeping_king_studios/yard/data/class_object'
    autoload :ConstantObject,
      'sleeping_king_studios/yard/data/constant_object'
    autoload :Metadata,
      'sleeping_king_studios/yard/data/metadata'
    autoload :MethodObject,
      'sleeping_king_studios/yard/data/method_object'
    autoload :ModuleObject,
      'sleeping_king_studios/yard/data/module_object'
    autoload :NamespaceObject,
      'sleeping_king_studios/yard/data/namespace_object'
    autoload :SeeTag,
      'sleeping_king_studios/yard/data/see_tag'
    autoload :Types,
      'sleeping_king_studios/yard/data/types'
  end
end
