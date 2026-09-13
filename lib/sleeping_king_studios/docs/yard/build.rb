# frozen_string_literal: true

require 'cuprum'

require 'sleeping_king_studios/docs/yard'

module SleepingKingStudios::Docs::Yard
  # Command for creating generic data objects from YARD objects.
  class Build < Cuprum::Command
    DATA_TYPES = {
      YARD::CodeObjects::RootObject     =>
        SleepingKingStudios::Docs::Data::RootObject,
      YARD::CodeObjects::ClassObject    =>
        SleepingKingStudios::Docs::Data::ClassObject,
      YARD::CodeObjects::ConstantObject =>
        SleepingKingStudios::Docs::Data::ConstantObject,
      YARD::CodeObjects::MethodObject   =>
        SleepingKingStudios::Docs::Data::MethodObject,
      YARD::CodeObjects::ModuleObject   =>
        SleepingKingStudios::Docs::Data::ModuleObject
    }.freeze
    private_constant :DATA_TYPES

    private

    def process(native)
      matching = DATA_TYPES.each_key.find { |type| native.is_a?(type) }

      return failure(unknown_type_error(native)) unless matching

      DATA_TYPES[matching].new(native:)
    end

    def unknown_type_error(native)
      message =
        "unable to parse native object #{native.inspect} - no matching data" \
        "type defined for #{native.class}"

      SleepingKingStudios::Docs::Errors::RegistryError.new(message:)
    end
  end
end
