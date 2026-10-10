# frozen_string_literal: true

require 'cuprum/error'

require 'sleeping_king_studios/docs/errors'

module SleepingKingStudios::Docs::Errors
  # Error returned when the checked documentation does not match the code.
  class OutdatedDocumentation < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'sleeping_king_studios.docs.errors.outdated_documentation'

    # @param docs_path [String] the path to the generated documentation.
    # @param version [String, nil] the version of the generated documentation.
    # @param changed_files [Array<String>] the list of docs files with missing
    #   or non-matching checksums.
    # @param extra_files [Array<String>] the list of additional files in the
    #   docs directory.
    # @param missing_files [Array<String>] the list of missing docs files based
    #   on the registered code.
    def initialize( # rubocop:disable Metrics/MethodLength
      docs_path:,
      changed_files: [],
      extra_files:   [],
      missing_files: [],
      version:       nil
    )
      @changed_files = changed_files
      @docs_path     = docs_path
      @extra_files   = extra_files
      @missing_files = missing_files
      @version       = version

      super(
        changed_files:,
        docs_path:,
        extra_files:,
        message:       default_message,
        missing_files:,
        version:
      )
    end

    # @return [Array<String>] the list of docs files with missing or
    #   non-matching checksums.
    attr_reader :changed_files

    # @return [String] the path to the generated documentation.
    attr_reader :docs_path

    # @return [Array<String>] the list of additional files in the docs
    #   directory.
    attr_reader :extra_files

    # @return [Array<String>] the list of missing docs files based on the
    #   registered code.
    attr_reader :missing_files

    # @return [String, nil] the version of the generated documentation.
    attr_reader :version

    private

    def as_json_data
      {
        'changed_files' => changed_files,
        'docs_path'     => docs_path,
        'extra_files'   => extra_files,
        'missing_files' => missing_files,
        'version'       => version
      }
    end

    def default_message
      'outdated documentation found for ' \
        "#{version ? "version #{version}" : 'current version'}"
    end
  end
end
