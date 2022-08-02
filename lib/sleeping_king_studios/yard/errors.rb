# frozen_string_literal: true

require 'sleeping_king_studios/yard'

module SleepingKingStudios::Yard
  # Namespace for error objects, which encapsulate command failure states.
  module Errors
    autoload :FileAlreadyExists,
      'sleeping_king_studios/yard/errors/file_already_exists'
    autoload :FileError,
      'sleeping_king_studios/yard/errors/file_error'
    autoload :FileNotFound,
      'sleeping_king_studios/yard/errors/file_not_found'
    autoload :InvalidDirectory,
      'sleeping_king_studios/yard/errors/invalid_directory'
    autoload :InvalidFile,
      'sleeping_king_studios/yard/errors/invalid_file'
  end
end
