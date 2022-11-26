# frozen_string_literal: true

require 'sleeping_king_studios/yard/data'

module SleepingKingStudios::Yard::Data
  # Namespace for objects representing YARD @see tags.
  module SeeTags
    autoload :Base,
      'sleeping_king_studios/yard/data/see_tags/base'
    autoload :ClassMethodTag,
      'sleeping_king_studios/yard/data/see_tags/class_method_tag'
    autoload :ConstantTag,
      'sleeping_king_studios/yard/data/see_tags/constant_tag'
    autoload :DefinitionTag,
      'sleeping_king_studios/yard/data/see_tags/definition_tag'
    autoload :LinkTag,
      'sleeping_king_studios/yard/data/see_tags/link_tag'
    autoload :NamespaceItemTag,
      'sleeping_king_studios/yard/data/see_tags/namespace_item_tag'
    autoload :ReferenceTag,
      'sleeping_king_studios/yard/data/see_tags/reference_tag'
    autoload :TextTag,
      'sleeping_king_studios/yard/data/see_tags/text_tag'
  end
end
