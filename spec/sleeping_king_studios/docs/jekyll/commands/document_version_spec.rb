# frozen_string_literal: true

require 'cuprum/cli/rspec/deferred/arguments_examples'
require 'cuprum/cli/rspec/deferred/options_examples'

require 'sleeping_king_studios/docs/jekyll/commands/document_version'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Commands::DocumentVersion do
  include Cuprum::Cli::RSpec::Deferred::ArgumentsExamples
  include Cuprum::Cli::RSpec::Deferred::OptionsExamples

  subject(:command) { described_class.new(file_system:, standard_io:) }

  let(:docs_path) { 'docs' }
  let(:files) do
    { docs_path => { 'index.md' => "---\n---\n\n# Docs Index\n" } }
  end
  let(:file_system) { Cuprum::Cli::Dependencies::FileSystem::Mock.new(files:) }
  let(:standard_io) { Cuprum::Cli::Dependencies::StandardIo::Mock.new }

  include_deferred 'should define argument',
    0,
    :version,
    type:     :string,
    required: true

  include_deferred 'should define option',
    :docs_path,
    type:    :string,
    default: 'docs'

  include_deferred 'should define option',
    :dry_run,
    type:    :boolean,
    default: false

  include_deferred 'should define --quiet option'

  include_deferred 'should define --verbose option'

  describe '#call' do
    deferred_examples 'should generate the documentation files' do
      it 'should generate the reference files' do # rubocop:disable RSpec/ExampleLength
        call_command

        expect(generate_reference_command)
          .to have_received(:call)
          .with(
            docs_path:,
            dry_run:   options.fetch(:dry_run, false),
            quiet:     options.fetch(:quiet,   false),
            verbose:   options.fetch(:verbose, false),
            version:
          )
      end

      it 'should generate the version file', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        expect { call_command }.to(
          change { file_system.file?(expected_version_file_path) }
          .to(be true)
        )

        expect(file_system.read_file(expected_version_file_path))
          .to eq(expected_version_file_contents)
      end

      it 'should copy the static files and update breadcrumbs',
        :aggregate_failures \
      do
        call_command

        expected_static_files.each do |file_path, contents|
          expect(file_system.read_file(file_path)).to eq(contents)
        end
      end
    end

    deferred_examples 'should output to standard IO' do
      it 'should output to STDOUT' do
        call_command

        expect(standard_io.output_stream.string).to eq(expected_output)
      end

      it 'should not output to STDERR' do
        call_command

        expect(standard_io.error_stream.string).to eq('')
      end

      describe 'with quiet: true' do
        let(:options) { super().merge(quiet: true) }

        it 'should not output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq('')
        end

        it 'should not output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq('')
        end
      end

      describe 'with verbose: true' do
        let(:options) { super().merge(verbose: true) }

        it 'should output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq(expected_output)
        end

        it 'should not output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq('')
        end
      end
    end

    let(:version) { '1.23.4' }
    let(:options) { {} }
    let(:generated_reference_files) do
      [
        "#{docs_path}/_modules/version--#{version}/space.yml",
        "#{docs_path}/versions/#{version}/reference/space.md"
      ]
    end
    let(:generate_reference_command) do
      instance_double(
        SleepingKingStudios::Docs::Jekyll::Commands::Generate,
        call: nil
      )
    end
    let(:expected_version_file_path) do
      "#{docs_path}/_versions/#{version.tr('.', '-')}.yml"
    end
    let(:expected_version_file_contents) do
      <<~YAML
        ---
        version: "1.23.4"
        sortable: "001.023.004"
      YAML
    end
    let(:expected_static_files) do
      expected_index_contents = <<~MARKDOWN
        ---
        breadcrumbs:
        - name: Documentation
          path: "/"
        - name: Versions
          path: "/versions"
        version: #{version}
        ---

        # Docs Index
      MARKDOWN

      {
        "#{docs_path}/versions/#{version}/index.md" => expected_index_contents
      }
    end
    let(:expected_value) do
      generated_reference_files
        .append(expected_version_file_path)
        .concat(expected_static_files.keys)
    end
    let(:expected_output) do
      output = "Generating pinned documentation for version #{version}\n\n"
      output << "Generating data and reference files:\n"
      output << "\n" if options.fetch(:verbose, false)

      generated_reference_files.each do |file_path|
        output << "Generating file #{file_path}...\n"
      end

      output << "\n"
      output << "Generating version file:\n"
      output << "\n" if options.fetch(:verbose, false)
      output << "Generating file #{expected_version_file_path}...\n"

      if options.fetch(:verbose, false)
        output << "\n"
        output << indent(expected_version_file_contents)
      end

      output << "\n" if options.fetch(:verbose, false)
      output << "\n"
      output << "Copying static documentation...\n"
      output << "\n" if options.fetch(:verbose, false)

      expected_static_files.each do |file_path, contents|
        output << "Generating file #{file_path}...\n"

        next unless options.fetch(:verbose, false)

        output << "\n"
        output << indent(contents)
      end

      output << "\n"
      output << "\n" if options.fetch(:verbose, false)
      output << 'Success!'
      output << "\n"
    end

    define_method :call_command do
      command.call(version, **options)
    end

    define_method :indent do |str|
      str
        .each_line
        .map { |line| line == "\n" ? line : "  #{line}" }
        .join
    end

    before(:example) do
      allow(SleepingKingStudios::Docs::Jekyll::Commands::Generate)
        .to receive(:new)
        .with(file_system:, standard_io:)
        .and_return(generate_reference_command)

      allow(generate_reference_command).to receive(:call) do
        generated_reference_files.each do |file_path|
          next if options.fetch(:quiet, false)

          standard_io.write_output "Generating file #{file_path}..."
        end

        Cuprum::Result.new(value: generated_reference_files)
      end
    end

    it 'should return a passing result with the generated file paths' do
      expect(call_command)
        .to be_a_passing_result
        .with_value(expected_value)
    end

    include_deferred 'should generate the documentation files'

    include_deferred 'should output to standard IO'

    describe 'with docs_path: value' do
      let(:docs_path) { 'path/to/docs' }
      let(:options)   { super().merge(docs_path:) }

      it 'should return a passing result with the generated file paths' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_value)
      end

      include_deferred 'should generate the documentation files'

      include_deferred 'should output to standard IO'
    end

    describe 'with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it 'should return a passing result with the generated file paths' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_value)
      end

      it 'should not update the file system' do
        expect { call_command }.not_to change(file_system, :files)
      end

      include_deferred 'should output to standard IO'
    end

    context 'when there are existing static files' do
      let(:existing_static_files) do
        reference_index_contents = <<~MARKDOWN
          ---
          ---

          # Space

          The final frontier.
        MARKDOWN

        versions_index_contents = <<~MARKDOWN
          ---
          ---

          This file should not be copied.
        MARKDOWN

        top_level_contents = <<~MARKDOWN
          ---
          breadcrumbs:
          - name: "Documentation"
            path: "/"
          version: 'N/A'
          custom_property: "Custom Value"
          ---
        MARKDOWN

        directory_index_contents = <<~MARKDOWN
          ---
          breadcrumbs:
          - name: "Documentation"
            path: "/"
          ---

          # Rocketry
        MARKDOWN

        directory_file_contents = <<~MARKDOWN
          ---
          breadcrumbs:
          - name: "Documentation"
            path: "/"
          - name: "Rocketry"
            path: "/rocketry"
          ---

          # Rocketry

          ## Assembly
        MARKDOWN

        {
          "#{docs_path}/reference/index.md"   => reference_index_contents,
          "#{docs_path}/versions/index.md"    => versions_index_contents,
          "#{docs_path}/top_level.md"         => top_level_contents,
          "#{docs_path}/rocketry/index.md"    => directory_index_contents,
          "#{docs_path}/rocketry/assembly.md" => directory_file_contents
        }
      end
      let(:expected_static_files) do
        relative_path = "#{docs_path}/versions/#{version}"

        reference_index_contents = <<~MARKDOWN
          ---
          breadcrumbs:
          - name: Documentation
            path: "/"
          - name: Versions
            path: "/versions"
          - name: Version #{version}
            path: "/versions/#{version}"
          - name: Reference
            path: "/versions/#{version}/reference"
          version: #{version}
          ---

          # Space

          The final frontier.
        MARKDOWN

        top_level_contents = <<~MARKDOWN
          ---
          breadcrumbs:
          - name: Documentation
            path: "/"
          - name: Versions
            path: "/versions"
          - name: Version #{version}
            path: "/versions/#{version}"
          version: #{version}
          custom_property: Custom Value
          ---
        MARKDOWN

        directory_index_contents = <<~MARKDOWN
          ---
          breadcrumbs:
          - name: Documentation
            path: "/"
          - name: Versions
            path: "/versions"
          - name: Version #{version}
            path: "/versions/#{version}"
          version: #{version}
          ---

          # Rocketry
        MARKDOWN

        directory_file_contents = <<~MARKDOWN
          ---
          breadcrumbs:
          - name: Documentation
            path: "/"
          - name: Versions
            path: "/versions"
          - name: Version #{version}
            path: "/versions/#{version}"
          - name: Rocketry
            path: "/versions/#{version}/rocketry"
          version: #{version}
          ---

          # Rocketry

          ## Assembly
        MARKDOWN

        super().merge(
          "#{relative_path}/reference/index.md"   => reference_index_contents,
          "#{relative_path}/top_level.md"         => top_level_contents,
          "#{relative_path}/rocketry/index.md"    => directory_index_contents,
          "#{relative_path}/rocketry/assembly.md" => directory_file_contents
        )
      end
      let(:files) { super().merge(existing_static_files) }

      it 'should return a passing result with the generated file paths' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(match_array(expected_value))
      end

      include_deferred 'should generate the documentation files'
    end

    context 'when conflicting reference files exist' do
      let(:reference_error) do
        path    = "#{docs_path}/_classes/space"
        message =
          "unable to delete directory #{path} - directory is not empty"

        SleepingKingStudios::Docs::Errors::FileError.new(message:, path:)
      end

      before(:example) do
        allow(generate_reference_command)
          .to receive(:call)
          .and_return(Cuprum::Result.new(error: reference_error))
      end

      it 'should return a failing result with the reference command error' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(reference_error)
      end

      it 'should not update the file system' do
        expect { call_command }.not_to change(file_system, :files)
      end
    end

    context 'when the version file already exists' do
      let(:files) do
        super().merge(expected_version_file_path => 'Existing file.')
      end
      let(:expected_error) do
        Cuprum::Cli::Files::Errors::FileNotWriteable.new(
          file_path: expected_version_file_path,
          reason:    'file already exists'
        )
      end

      it 'should return a failing result with a file error' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should not update the file system' do
        expect { call_command }.not_to change(file_system, :files)
      end
    end
  end
end
