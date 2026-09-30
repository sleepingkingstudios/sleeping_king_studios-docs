# frozen_string_literal: true

require 'cuprum/cli/rspec/deferred/generators_examples'
require 'cuprum/cli/rspec/deferred/options_examples'

require 'sleeping_king_studios/docs/jekyll/commands/backfill_versions'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Commands::BackfillVersions do
  include Cuprum::Cli::RSpec::Deferred::OptionsExamples

  subject(:command) { described_class.new(file_system:, standard_io:) }

  let(:docs_path)   { 'docs' }
  let(:files)       { { docs_path => {} } }
  let(:file_system) { Cuprum::Cli::Dependencies::FileSystem::Mock.new(files:) }
  let(:standard_io) { Cuprum::Cli::Dependencies::StandardIo::Mock.new }
  let(:options)     { {} }

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
    deferred_examples 'should output to standard IO' do |with_error: false|
      it 'should output to STDOUT' do
        command.call(**options)

        expect(standard_io.output_stream.string).to eq(expected_output)
      end

      if with_error
        it 'should output to STDERR' do
          command.call(**options)

          expect(standard_io.error_stream.string).to eq(expected_error_output)
        end
      else
        it 'should not output to STDERR' do
          command.call(**options)

          expect(standard_io.error_stream.string).to eq('')
        end
      end

      describe 'when initialized with quiet: true' do
        let(:options) { super().merge(quiet: true) }

        it 'should not output to STDOUT' do
          command.call(**options)

          expect(standard_io.output_stream.string).to eq('')
        end

        if with_error
          it 'should output to STDERR' do
            command.call(**options)

            expect(standard_io.error_stream.string).to eq(expected_error_output)
          end
        else
          it 'should not output to STDERR' do
            command.call(**options)

            expect(standard_io.error_stream.string).to eq('')
          end
        end
      end

      describe 'with verbose: true' do
        let(:options) { super().merge(verbose: true) }

        it 'should output to STDOUT' do
          command.call(**options)

          expect(standard_io.output_stream.string).to eq(expected_output)
        end

        if with_error
          it 'should output to STDERR' do
            command.call(**options)

            expect(standard_io.error_stream.string).to eq(expected_error_output)
          end
        else
          it 'should not output to STDERR' do
            command.call(**options)

            expect(standard_io.error_stream.string).to eq('')
          end
        end
      end
    end

    let(:expected_files) { {} }
    let(:config_output) do
      <<~OUTPUT
        Checking _config.yml for existing versions...
      OUTPUT
    end
    let(:directories_output) do
      <<~OUTPUT
        Checking versions directory for existing versions...
      OUTPUT
    end
    let(:generated_files_output) do
      next if expected_files.empty?

      output = "\n"

      expected_files
        .each do |file_path, contents|
          message = "Generating file #{file_path}..."

          output += "#{message}\n"

          next unless options[:verbose]

          output += "\n#{indent(contents)}\n"
        end

      output.sub(/\n+\z/, "\n")
    end
    let(:expected_output) do
      <<~OUTPUT
        #{config_output}
        #{directories_output}
        Successfully generated versions collection at #{docs_path}/_versions.
        #{generated_files_output}
        Next Steps

          Update _config.yml:

          - In #{docs_path}/_config.yml, add `versions: { output: false }` to `collections`.
          - In #{docs_path}/_config.yml, remove `project_metadata.versions`.

          Update _includes/pages/index-versions.md:

          - In #{docs_path}/_includes/pages/index-versions.md, replace the latest_version check with the following:

          ```ruby
          {% assign latest_version = site.versions | sort: "sortable" | map: "version" | last %}
          ```

          Update versions/index.md:

          - In #{docs_path}/versions/index.md, replace the versions loop with the following:

          ```ruby
          {% assign versions = site.versions | sort: "sortable" | map: "version" | reverse %}
          {% for version in versions %}
          - [Version {{ version }}]({{site.baseurl}}/versions/{{version}})
          {%- endfor %}
          ```
      OUTPUT
    end
    let(:expected_error_output) do
      '  Unable to read config file - ' \
        'Cuprum::Cli::Dependencies::FileSystem::FileNotFoundError: unable to ' \
        "read file #{docs_path}/_config.yml - file not found\n\n"
    end

    define_method :call_command do
      command.call(**options)
    end

    define_method :indent do |str|
      str
        .each_line
        .map { |line| line == "\n" ? line : "  #{line}" }
        .join
    end

    it 'should return a passing result' do
      expect(call_command)
        .to be_a_passing_result
        .with_value(expected_files.keys)
    end

    it 'should create the _versions directory' do
      call_command

      collection_path = File.join(docs_path, '_versions')

      expect(file_system.directory?(collection_path)).to be true
    end

    include_deferred 'should output to standard IO', with_error: true

    describe 'with docs_path: value' do
      let(:docs_path) { 'path/to/docs' }
      let(:options)   { super().merge(docs_path:) }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should create the _versions directory' do
        call_command

        collection_path = File.join(docs_path, '_versions')

        expect(file_system.directory?(collection_path)).to be true
      end

      include_deferred 'should output to standard IO', with_error: true
    end

    describe 'with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should not change the filesystem' do
        expect { call_command }.not_to change(file_system, :files)
      end

      include_deferred 'should output to standard IO', with_error: true
    end

    context 'when the config file exists with invalid YAML' do
      let(:files) do
        { docs_path => { '_config.yml' => "---\nproject_metadata: {" } }
      end
      let(:expected_error_output) do
        "  Unable to parse config file at #{docs_path}/_config.yml - " \
          'Psych::SyntaxError: (<unknown>): did not find expected node ' \
          "content while parsing a flow node at line 3 column 1\n\n"
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should create the _versions directory' do
        call_command

        collection_path = File.join(docs_path, '_versions')

        expect(file_system.directory?(collection_path)).to be true
      end

      include_deferred 'should output to standard IO', with_error: true
    end

    context 'when the config file exists with missing versions' do
      let(:config) do
        <<~YAML
          ---
          project_metadata: {}
        YAML
      end
      let(:files) do
        { docs_path => { '_config.yml' => config } }
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should create the _versions directory' do
        call_command

        collection_path = File.join(docs_path, '_versions')

        expect(file_system.directory?(collection_path)).to be true
      end

      include_deferred 'should output to standard IO'
    end

    context 'when the config file exists with defined versions' do
      let(:config) do
        <<~YAML
          ---
          project_metadata:
            versions:
              - 0.1
              - 0.2
              - 1.0
        YAML
      end
      let(:files) do
        { docs_path => { '_config.yml' => config } }
      end
      let(:expected_versions) do
        {
          '0.1' => '000.001',
          '0.2' => '000.002',
          '1.0' => '001.000'
        }
      end
      let(:expected_files) do
        expected_versions.to_h do |version, sortable|
          file_path =
            File.join(docs_path, '_versions', "#{version.tr('.', '-')}.yml")
          contents  = <<~YAML
            ---
            version: "#{version}"
            sortable: "#{sortable}"
          YAML

          [file_path, contents]
        end
      end
      let(:config_output) do
        <<~OUTPUT
          Checking _config.yml for existing versions...

            Found versions 0.1, 0.2, 1.0
        OUTPUT
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should create the _versions directory' do
        call_command

        collection_path = File.join(docs_path, '_versions')

        expect(file_system.directory?(collection_path)).to be true
      end

      it 'should create the version files', :aggregate_failures do
        call_command

        expected_files.each do |file_path, contents|
          expect(file_system.read_file(file_path)).to eq(contents)
        end
      end

      include_deferred 'should output to standard IO'

      describe 'with docs_path: value' do
        let(:docs_path) { 'path/to/docs' }
        let(:options)   { super().merge(docs_path:) }

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_files.keys)
        end

        it 'should create the _versions directory' do
          call_command

          collection_path = File.join(docs_path, '_versions')

          expect(file_system.directory?(collection_path)).to be true
        end

        it 'should create the version files', :aggregate_failures do
          call_command

          expected_files.each do |file_path, contents|
            expect(file_system.read_file(file_path)).to eq(contents)
          end
        end

        include_deferred 'should output to standard IO'
      end

      describe 'with dry_run: true' do
        let(:options) { super().merge(dry_run: true) }

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_files.keys)
        end

        it 'should not change the filesystem' do
          expect { call_command }.not_to change(file_system, :files)
        end

        include_deferred 'should output to standard IO'
      end
    end

    context 'when the docs directory does not exist' do
      let(:files) { {} }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should create the _versions directory' do
        call_command

        collection_path = File.join(docs_path, '_versions')

        expect(file_system.directory?(collection_path)).to be true
      end

      include_deferred 'should output to standard IO', with_error: true
    end

    context 'when the versions directory has versions' do
      let(:files) do
        {
          docs_path => {
            'versions' => {
              '0.10'     => {},
              '1.0'      => {},
              '2.0'      => {},
              'index.md' => ''
            }
          }
        }
      end
      let(:expected_versions) do
        {
          '0.10' => '000.010',
          '1.0'  => '001.000',
          '2.0'  => '002.000'
        }
      end
      let(:expected_files) do
        expected_versions.to_h do |version, sortable|
          file_path =
            File.join(docs_path, '_versions', "#{version.tr('.', '-')}.yml")
          contents  = <<~YAML
            ---
            version: "#{version}"
            sortable: "#{sortable}"
          YAML

          [file_path, contents]
        end
      end
      let(:directories_output) do
        <<~OUTPUT
          Checking versions directory for existing versions...

            Found versions 0.10, 1.0, 2.0
        OUTPUT
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should create the _versions directory' do
        call_command

        collection_path = File.join(docs_path, '_versions')

        expect(file_system.directory?(collection_path)).to be true
      end

      it 'should create the version files', :aggregate_failures do
        call_command

        expected_files.each do |file_path, contents|
          expect(file_system.read_file(file_path)).to eq(contents)
        end
      end

      include_deferred 'should output to standard IO', with_error: true

      describe 'with docs_path: value' do
        let(:docs_path) { 'path/to/docs' }
        let(:options)   { super().merge(docs_path:) }

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_files.keys)
        end

        it 'should create the _versions directory' do
          call_command

          collection_path = File.join(docs_path, '_versions')

          expect(file_system.directory?(collection_path)).to be true
        end

        it 'should create the version files', :aggregate_failures do
          call_command

          expected_files.each do |file_path, contents|
            expect(file_system.read_file(file_path)).to eq(contents)
          end
        end

        include_deferred 'should output to standard IO', with_error: true
      end

      describe 'with dry_run: true' do
        let(:options) { super().merge(dry_run: true) }

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_files.keys)
        end

        it 'should not change the filesystem' do
          expect { call_command }.not_to change(file_system, :files)
        end

        include_deferred 'should output to standard IO', with_error: true
      end

      context 'when the versions directory has non-version directories' do
        let(:files) do
          files    = super()
          versions = files[docs_path]['versions'].merge(
            'other_dir' => {}
          )

          files.merge(
            docs_path => files[docs_path].merge('versions' => versions)
          )
        end

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_files.keys)
        end

        it 'should create the _versions directory' do
          call_command

          collection_path = File.join(docs_path, '_versions')

          expect(file_system.directory?(collection_path)).to be true
        end

        it 'should create the version files', :aggregate_failures do
          call_command

          expected_files.each do |file_path, contents|
            expect(file_system.read_file(file_path)).to eq(contents)
          end
        end

        include_deferred 'should output to standard IO', with_error: true
      end
    end

    context 'when both the config file and versions directory have versions' do
      let(:config) do
        <<~YAML
          ---
          project_metadata:
            versions:
              - 0.1
              - 0.2
              - 1.0
        YAML
      end
      let(:files) do
        {
          docs_path => {
            '_config.yml' => config,
            'versions'    => {
              '0.10'     => {},
              '1.0'      => {},
              '2.0'      => {},
              'index.md' => ''
            }
          }
        }
      end
      let(:expected_versions) do
        {
          '0.1'  => '000.001',
          '0.2'  => '000.002',
          '1.0'  => '001.000',
          '0.10' => '000.010',
          '2.0'  => '002.000'
        }
      end
      let(:expected_files) do
        expected_versions.to_h do |version, sortable|
          file_path =
            File.join(docs_path, '_versions', "#{version.tr('.', '-')}.yml")
          contents  = <<~YAML
            ---
            version: "#{version}"
            sortable: "#{sortable}"
          YAML

          [file_path, contents]
        end
      end
      let(:config_output) do
        <<~OUTPUT
          Checking _config.yml for existing versions...

            Found versions 0.1, 0.2, 1.0
        OUTPUT
      end
      let(:directories_output) do
        <<~OUTPUT
          Checking versions directory for existing versions...

            Found versions 0.10, 1.0, 2.0
        OUTPUT
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should create the _versions directory' do
        call_command

        collection_path = File.join(docs_path, '_versions')

        expect(file_system.directory?(collection_path)).to be true
      end

      it 'should create the version files', :aggregate_failures do
        call_command

        expected_files.each do |file_path, contents|
          expect(file_system.read_file(file_path)).to eq(contents)
        end
      end

      include_deferred 'should output to standard IO'

      describe 'with docs_path: value' do
        let(:docs_path) { 'path/to/docs' }
        let(:options)   { super().merge(docs_path:) }

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_files.keys)
        end

        it 'should create the _versions directory' do
          call_command

          collection_path = File.join(docs_path, '_versions')

          expect(file_system.directory?(collection_path)).to be true
        end

        it 'should create the version files', :aggregate_failures do
          call_command

          expected_files.each do |file_path, contents|
            expect(file_system.read_file(file_path)).to eq(contents)
          end
        end

        include_deferred 'should output to standard IO'
      end

      describe 'with dry_run: true' do
        let(:options) { super().merge(dry_run: true) }

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_files.keys)
        end

        it 'should not change the filesystem' do
          expect { call_command }.not_to change(file_system, :files)
        end

        include_deferred 'should output to standard IO'
      end
    end
  end
end
