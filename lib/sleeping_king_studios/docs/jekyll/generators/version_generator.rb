# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/generators'

module SleepingKingStudios::Docs::Jekyll::Generators
  # Generator class for writing versions as Jekyll collection items.
  class VersionGenerator < Cuprum::Cli::Files::Generator
    TEMPLATE = Cuprum::Cli::Files::Templates::StringTemplate.new(
      engine:       Cuprum::Cli::Files::Engines::ERB,
      raw_template: <<~TEMPLATE
        ---
        version: "<%= version %>"
        sortable: "<%= sortable_version %>"
      TEMPLATE
    ).freeze
    private_constant :TEMPLATE

    option :docs_path,
      type:    :string,
      default: 'docs'

    option :version,
      type:     :string,
      required: true

    output '%<docs_path>s/_versions/%<version_slug>s.yml',
      template: TEMPLATE

    # @return [Hash] parameters used to resolve output file paths and
    #   contents.
    def parameters
      super.merge(sortable_version:, version_slug:)
    end

    # Generates a sortable copy of the version string.
    #
    # Splits the string into `.`-delineated segments, then left-pads each
    # numeric segment with zeroes to a length of 3.
    #
    # @return [String] the sortable version string.
    #
    # @example
    #   generator =
    #     SleepingKingStudios::Docs::Jekyll::Generators::Generator
    #     .new(version: '0.10.2')
    #
    #   generator.sortable_version
    #   #=> '000.010.002'
    def sortable_version
      version
        .split('.')
        .map do |segment|
          next segment unless segment =~ /\A\d+\z/

          format('%03i', segment)
        end
        .join('.')
    end

    # @return [String] the version string, with `.` characters converted to
    #   dashes for use in file names.
    def version_slug
      version.tr('.', '-')
    end
  end
end
