# frozen_string_literal: true

require 'sleeping_king_studios/yard/data'

module SleepingKingStudios::Yard::Data
  # Namespace for types, which represent a YARD type list.
  #
  # @see https://www.rubydoc.info/gems/yard/file/docs/Tags.md#types-specifier-list
  module Types
    autoload :KeyValueType,
      'sleeping_king_studios/yard/data/types/key_value_type'
    autoload :ParameterizedType,
      'sleeping_king_studios/yard/data/types/parameterized_type'
    autoload :Parser,
      'sleeping_king_studios/yard/data/types/parser'
    autoload :Type,
      'sleeping_king_studios/yard/data/types/type'
  end
end
