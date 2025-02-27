# frozen_string_literal: true

require 'sleeping_king_studios/docs'

module SleepingKingStudios::Docs
  # Namespace for data objects, which represent documented code.
  module Data
    autoload :Base,
      'sleeping_king_studios/docs/data/base'
    autoload :ClassObject,
      'sleeping_king_studios/docs/data/class_object'
    autoload :ConstantObject,
      'sleeping_king_studios/docs/data/constant_object'
    autoload :Metadata,
      'sleeping_king_studios/docs/data/metadata'
    autoload :MethodObject,
      'sleeping_king_studios/docs/data/method_object'
    autoload :ModuleObject,
      'sleeping_king_studios/docs/data/module_object'
    autoload :NamespaceObject,
      'sleeping_king_studios/docs/data/namespace_object'
    autoload :RootObject,
      'sleeping_king_studios/docs/data/root_object'
    autoload :SeeTags,
      'sleeping_king_studios/docs/data/see_tags'
    autoload :Types,
      'sleeping_king_studios/docs/data/types'
  end
end
