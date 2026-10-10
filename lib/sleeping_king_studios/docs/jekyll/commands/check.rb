# frozen_string_literal: true

require 'yaml'

require 'sleeping_king_studios/docs/jekyll/commands'

module SleepingKingStudios::Docs::Jekyll::Commands
  # Checks whether the current documentation is up to date.
  class Check < SleepingKingStudios::Docs::Jekyll::Commands::Reference # rubocop:disable Metrics/ClassLength
    full_name 'docs:jekyll:check'

    description 'Checks whether the current documentation is up to date'

    option :inspect_changes,
      aliases: %i[inspect],
      type:    :boolean,
      default: false

    private

    attr_reader :changed_files

    attr_reader :extra_files

    attr_reader :missing_files

    attr_reader :registry

    def build_command
      @build_command ||= SleepingKingStudios::Docs::Yard::Build.new
    end

    def collection_path_for(data)
      data_type = data_type_for(data)

      data_collections[data_type]
    end

    def compare_files(actual:, expected:)
      # Skip the full analysis if all files are matching.
      return if actual == expected

      missing  = find_missing_files(actual:, expected:)
      extra    = find_extra_files(actual:, expected:)
      matching = expected.except(*missing).reject { |_, value| value == true }
      changed  = find_changed_files(actual:, matching:)

      @missing_files.concat(missing)
      @extra_files.concat(extra)
      @changed_files.concat(changed)
    end

    def data_collections
      @data_collections ||= Hash.new do |hsh, data_type|
        hsh[data_type] = tools.string_tools.pluralize(data_type)
      end
    end

    def data_file_for(data)
      "#{data_path_for(data)}/#{data.data_path}.yml"
    end

    def data_path_for(data)
      collection_path = collection_path_for(data)

      if version
        File.join(docs_path, "_#{collection_path}", "version--#{version}")
      else
        File.join(docs_path, "_#{collection_path}")
      end
    end

    def data_type_for(data)
      data
        .class
        .name
        .split('::')
        .last
        .sub(/Object\z/, '')
        .then { |str| tools.string_tools.underscore(str) }
        .then { |str| str == 'root' ? 'namespace' : str }
    end

    def file_not_found_error(**)
      SleepingKingStudios::Docs::Errors::FileError.new(**)
    end

    def find_changed_files(actual:, matching:)
      return [] if matching.empty?

      matching
        .reject { |key, value| value == actual[key] }
        .keys
    end

    def find_data_files
      [
        *each_data_file(class_data_directory),
        *each_data_file(constant_data_directory),
        *each_data_file(method_data_directory),
        *each_data_file(module_data_directory),
        *each_data_file(namespace_data_directory)
      ]
        .to_h { |file_path| [file_path, step { read_checksum(file_path) }] }
    end

    def find_expected_files
      expected_data      = {}
      expected_reference = {}

      registry.each do |native|
        data = step { build_command.call(native) }

        next unless data.public?

        expected_data[data_file_for(data)] = data.checksum

        next unless reference?(data)

        expected_reference[reference_file_for(data)] = true
      end

      [expected_data, expected_reference]
    end

    def find_extra_files(actual:, expected:)
      actual.each_key.reject { |key| expected.key?(key) }
    end

    def find_missing_files(actual:, expected:)
      expected.each_key.reject { |key| actual.key?(key) }
    end

    def find_native_object_for(file_path)
      registry.each do |native|
        data = step { build_command.call(native) }

        next unless data.public?

        next unless file_path == data_file_for(data)

        return data
      end

      # :nocov:
      nil
      # :nocov:
    end

    def find_reference_files
      each_reference_file.to_h { |file_path| [file_path, true] }
    end

    def generate_inspect_contents_for(object, mock_fs:)
      SleepingKingStudios::Docs::Jekyll::Generators::DataGenerator
        .new(object:, file_system: mock_fs, standard_io:, quiet: true)
        .call
    end

    def indent(contents)
      contents
        .each_line
        .map do |line|
          next "\n" if line == "\n"

          "  #{line}"
        end
        .join
    end

    def inspect_changed_files # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return unless inspect_changes? && !changed_files.empty?

      say "\n"
      say '-' * 80
      say "\n"

      mock_fs = Cuprum::Cli::Dependencies::FileSystem::Mock.new

      changed_files.each do |file_path|
        data   = find_native_object_for(file_path)
        result = generate_inspect_contents_for(data, mock_fs:)

        next unless result.success?

        say "Changed file #{file_path}:\n\n"

        contents = mock_fs.read(file_path)

        say indent(contents)
        say "\n"
      end
    end

    def outdated_documentation_error
      SleepingKingStudios::Docs::Errors::OutdatedDocumentation.new(
        docs_path:,
        version:,
        changed_files:,
        extra_files:,
        missing_files:
      )
    end

    def parse_registry # rubocop:disable Metrics/MethodLength
      @registry = step do
        SleepingKingStudios::Docs::Yard::Parse.new.call
      end

      SleepingKingStudios::Docs::Yard::Registry
        .provider
        .set(:registry, registry)

      registry
    rescue Plumbum::Errors::ImmutableError => exception
      message = "#{exception.class}: #{exception.message}"
      error   = SleepingKingStudios::Docs::Errors::RegistryError.new(message:)

      failure(error)
    end

    def process # rubocop:disable Metrics/MethodLength
      say "Checking documentation for #{version_string}..."
      say "\n", verbose: true

      @missing_files  = []
      @extra_files    = []
      @changed_files  = []
      data_files      = step { find_data_files }
      reference_files = step { find_reference_files }

      step { parse_registry }

      expected_data_files, expected_reference_files = step do
        find_expected_files
      end

      compare_files(actual: data_files,      expected: expected_data_files)
      compare_files(actual: reference_files, expected: expected_reference_files)

      report_results
    end

    def read_checksum(file_path) # rubocop:disable Metrics/MethodLength
      raw  = file_system.read(file_path)
      yaml = YAML.safe_load(raw)

      yaml.fetch('checksum') do
        warn_missing_checksum(file_path)

        nil
      end
    rescue Cuprum::Cli::Dependencies::FileSystem::FileError => exception
      failure(file_not_found_error(message: exception.message, path: file_path))
    rescue Psych::SyntaxError => exception
      message =
        "unable to parse file - error occurred on line #{exception.line}, " \
        "column #{exception.column}"

      failure(file_not_found_error(message:, path: file_path))
    end

    def reference?(data)
      data.is_a?(SleepingKingStudios::Docs::Data::ModuleObject)
    end

    def reference_file_for(data)
      "#{reference_path}/#{data.data_path}.md"
    end

    def reference_path
      @reference_path ||=
        if version
          File.join(docs_path, 'versions', version, 'reference')
        else
          File.join(docs_path, 'reference')
        end
    end

    def report_changed_files
      return if changed_files.empty?

      say 'Changed files:', verbose: true
      say "\n", verbose: true

      changed_files.each do |file_path|
        say "  - Changed file #{file_path}"
      end

      say "\n", verbose: true
    end

    def report_extra_files
      return if extra_files.empty?

      say 'Extra files:', verbose: true
      say "\n", verbose: true

      extra_files.each do |file_path|
        say "  - Extra file #{file_path}"
      end

      say "\n", verbose: true
    end

    def report_missing_files
      return if missing_files.empty?

      say 'Missing files:', verbose: true
      say "\n", verbose: true

      missing_files.each do |file_path|
        say "  - Missing file #{file_path}"
      end

      say "\n", verbose: true
    end

    def report_results
      if changed_files.empty? && missing_files.empty? && extra_files.empty?
        say 'Success!'

        return []
      end

      report_missing_files
      report_extra_files
      report_changed_files

      say 'Failure!'

      inspect_changed_files

      failure(outdated_documentation_error)
    end

    def version_string
      version ? "version #{version}" : 'current version'
    end

    def warn_missing_checksum(file_path)
      message = "Warning: file #{file_path} does not have a valid checksum\n"

      standard_io.write_error(message)
    end
  end
end
