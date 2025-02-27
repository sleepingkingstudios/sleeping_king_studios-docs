# frozen_string_literal: true

require 'sleeping_king_studios/docs/data'

module SleepingKingStudios::Docs::Data
  # Object representing the top-level Ruby namespace.
  #
  # Each namespace can define the following elements:
  #
  # - Definitions (classes and modules).
  # - Constants.
  # - Class attributes.
  # - Class methods.
  # - Instance attributes.
  # - Instance methods.
  #
  # @see SleepingKingStudios::Docs::Data::NamespaceObject
  class RootObject < SleepingKingStudios::Docs::Data::NamespaceObject
    # The path to the data file.
    #
    # @return [String] the file path.
    def data_path
      'root'
    end

    # The full, qualified name of the namespace.
    #
    # @return [String] the qualified name.
    def name
      'root'
    end

    # The name of the namespace in url-safe format.
    #
    # @return [String] the namespace name.
    def slug
      'root'
    end
  end
end
