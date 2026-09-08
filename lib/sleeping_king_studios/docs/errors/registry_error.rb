# frozen_string_literal: true

require 'cuprum/error'

require 'sleeping_king_studios/docs/errors'

module SleepingKingStudios::Docs::Errors
  # Error returned when an invalid registry operation is performed.
  class RegistryError < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'sleeping_king_studios.docs.errors.registry_error'
  end
end
