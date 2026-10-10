# frozen_string_literal: true

require 'cuprum/cli/rspec/deferred/options_examples'

require 'sleeping_king_studios/docs/jekyll/commands/check'

require 'support/deferred/reference_examples'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Commands::Check do
  include Cuprum::Cli::RSpec::Deferred::OptionsExamples
  include Spec::Support::Deferred::ReferenceExamples

  subject(:command) { described_class.new(file_system:, standard_io:) }

  let(:docs_path) { 'docs' }
  let(:files) do
    {
      docs_path => {
        '_modules/version--1.0/space.yml' => 'Ignored versioned data file.',
        'index.md'                        => 'Ignored index file.',
        'space.md'                        => 'Ignored static file.',
        'versions/1.0/reference/space.md' => 'Ignored versioned reference file.'
      }
    }
  end
  let(:file_system) { Cuprum::Cli::Dependencies::FileSystem::Mock.new(files:) }
  let(:standard_io) { Cuprum::Cli::Dependencies::StandardIo::Mock.new }
  let(:options)     { {} }

  before(:example) do
    allow(SleepingKingStudios::Docs::Yard::Registry.provider)
      .to receive(:set)
      .with(
        :registry,
        an_instance_of(SleepingKingStudios::Docs::Yard::Registry)
      )
  end

  include_deferred 'should define option',
    :docs_path,
    type:    :string,
    default: 'docs'

  include_deferred 'should define option',
    :version,
    type: :string

  include_deferred 'should define --quiet option'

  include_deferred 'should define --verbose option'

  include_deferred 'should implement the path helpers'

  describe '#call' do
    deferred_examples 'should output to StandardIo' do |with_error: false|
      it 'should output to STDOUT' do
        call_command

        expect(standard_io.output_stream.string).to eq expected_output
      end

      if with_error
        it 'should output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq expected_error_output
        end
      else
        it 'should not output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq ''
        end
      end

      describe 'with quiet: true' do
        let(:options) { super().merge(quiet: true) }

        it 'should not output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq ''
        end

        if with_error
          it 'should output to STDERR' do
            call_command

            expect(standard_io.error_stream.string).to eq expected_error_output
          end
        else
          it 'should not output to STDERR' do
            call_command

            expect(standard_io.error_stream.string).to eq ''
          end
        end
      end

      describe 'with verbose: true' do
        let(:options) { super().merge(verbose: true) }

        it 'should output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq verbose_output
        end

        if with_error
          it 'should output to STDERR' do
            call_command

            expect(standard_io.error_stream.string).to eq expected_error_output
          end
        else
          it 'should not output to STDERR' do
            call_command

            expect(standard_io.error_stream.string).to eq ''
          end
        end
      end
    end

    let(:version)  { nil }
    let(:registry) { SleepingKingStudios::Docs::Yard::Registry::EMPTY }
    let(:parse_command) do
      instance_double(
        SleepingKingStudios::Docs::Yard::Parse,
        call: Cuprum::Result.new(value: registry)
      )
    end
    let(:expected_value) { [] }
    let(:changed_files)  { [] }
    let(:extra_files)    { [] }
    let(:missing_files)  { [] }
    let(:expected_error) do
      SleepingKingStudios::Docs::Errors::OutdatedDocumentation.new(
        docs_path:,
        version:,
        changed_files:,
        extra_files:,
        missing_files:
      )
    end
    let(:version_string) do
      version ? "version #{version}" : 'current version'
    end
    let(:expected_output) do
      output = "Checking documentation for #{version_string}...\n"

      missing_files.each do |file_path|
        output << "  - Missing file #{file_path}\n"
      end

      extra_files.each do |file_path|
        output << "  - Extra file #{file_path}\n"
      end

      changed_files.each do |file_path|
        output << "  - Changed file #{file_path}\n"
      end

      # rubocop:disable-next Style/ConditionalAssignment
      if changed_files.any? || extra_files.any? || missing_files.any?
        output << "Failure!\n"
      else
        output << "Success!\n"
      end
    end
    let(:verbose_output) do
      output = "Checking documentation for #{version_string}...\n\n"

      output << "Missing files:\n\n" if missing_files.any?

      missing_files.each do |file_path|
        output << "  - Missing file #{file_path}\n"
      end

      output << "\n" if missing_files.any?

      output << "Extra files:\n\n" if extra_files.any?

      extra_files.each do |file_path|
        output << "  - Extra file #{file_path}\n"
      end

      output << "\n" if extra_files.any?

      output << "Changed files:\n\n" if changed_files.any?

      changed_files.each do |file_path|
        output << "  - Changed file #{file_path}\n"
      end

      output << "\n" if changed_files.any?

      # rubocop:disable-next Style/ConditionalAssignment
      if changed_files.any? || extra_files.any? || missing_files.any?
        output << "Failure!\n"
      else
        output << "Success!\n"
      end
    end

    before(:example) do
      allow(SleepingKingStudios::Docs::Yard::Parse)
        .to receive(:new)
        .and_return(parse_command)
    end

    after(:example) do
      YARD::Registry.clear
    end

    define_method :call_command do
      command.call(**options)
    end

    it 'should return a passing result' do
      expect(call_command)
        .to be_a_passing_result
        .with_value(expected_value)
    end

    include_deferred 'should output to StandardIo'

    describe 'with docs_path: value' do
      let(:docs_path) { 'path/to/docs' }
      let(:options)   { super().merge(docs_path:) }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_value)
      end

      include_deferred 'should output to StandardIo'
    end

    describe 'with version: value' do
      let(:version) { '1.12.3' }
      let(:options) { super().merge(version:) }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_value)
      end

      include_deferred 'should output to StandardIo'
    end

    context 'when there are extra files' do
      let(:files) do
        version_string = version ? "version--#{version}/" : ''
        data_files     = {
          "_modules/#{version_string}space.yml" =>
            "---\nname: Space\nchecksum: D3ADB33F"
        }

        version_string  = version ? "versions/#{version}/" : ''
        reference_files = {
          "#{version_string}reference/space.md" => 'Extra reference file.'
        }

        files          = super()
        docs_files     = files.fetch(docs_path, {}).merge(
          **data_files,
          **reference_files
        )

        files.merge(docs_path => docs_files)
      end
      let(:extra_files) do
        data_version      = version ? "version--#{version}/" : ''
        reference_version = version ? "versions/#{version}/" : ''

        [
          "#{docs_path}/_modules/#{data_version}space.yml",
          "#{docs_path}/#{reference_version}reference/space.md"
        ]
      end

      it 'should return a failing result with an outdated docs error' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      include_deferred 'should output to StandardIo'

      describe 'with docs_path: value' do
        let(:docs_path) { 'path/to/docs' }
        let(:options)   { super().merge(docs_path:) }

        it 'should return a failing result with an outdated docs error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end

        include_deferred 'should output to StandardIo'
      end

      describe 'with version: value' do
        let(:version) { '1.12.3' }
        let(:options) { super().merge(version:) }

        it 'should return a failing result with an outdated docs error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end

        include_deferred 'should output to StandardIo'
      end
    end

    context 'when an existing file cannot be read' do
      let(:files) do
        files      = super()
        docs_files = files.fetch(docs_path, {}).merge(
          '_modules/space.yml' => "---\nname: Space\nchecksum: D3ADB33F"
        )

        files.merge(docs_path => docs_files)
      end
      let(:expected_error) do
        path    = "#{docs_path}/_modules/space.yml"
        message = "unable to read file #{path} - file not found"

        SleepingKingStudios::Docs::Errors::FileError.new(message:, path:)
      end
      let(:expected_output) do
        "Checking documentation for #{version_string}...\n"
      end
      let(:verbose_output) do
        "Checking documentation for #{version_string}...\n\n"
      end

      before(:example) do
        allow(file_system).to receive(:read)

        path    = "#{docs_path}/_modules/space.yml"
        message = "unable to read file #{path} - file not found"

        allow(file_system)
          .to receive(:read)
          .with(path)
          .and_raise(
            Cuprum::Cli::Dependencies::FileSystem::FileNotFoundError,
            message
          )
      end

      it 'should return a failing result with a file error' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      include_deferred 'should output to StandardIo'
    end

    context 'when an existing file cannot be parsed' do
      let(:files) do
        files      = super()
        docs_files = files.fetch(docs_path, {}).merge(
          '_modules/space.yml' => "---\nname: {"
        )

        files.merge(docs_path => docs_files)
      end
      let(:expected_error) do
        path    = "#{docs_path}/_modules/space.yml"
        message = 'unable to parse file - error occurred on line 3, column 1'

        SleepingKingStudios::Docs::Errors::FileError.new(message:, path:)
      end
      let(:expected_output) do
        "Checking documentation for #{version_string}...\n"
      end
      let(:verbose_output) do
        "Checking documentation for #{version_string}...\n\n"
      end

      it 'should return a failing result with a file error' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      include_deferred 'should output to StandardIo'
    end

    context 'when the registry provider already has a value' do
      let(:expected_error) do
        message =
          'Plumbum::Errors::ImmutableError: unable to change immutable value ' \
          'for Plumbum::OneProvider with key "registry"'

        SleepingKingStudios::Docs::Errors::RegistryError.new(message:)
      end

      before(:example) do
        allow(SleepingKingStudios::Docs::Yard::Registry.provider)
          .to receive(:set)
          .and_call_original

        allow(SleepingKingStudios::Docs::Yard::Registry.provider)
          .to receive(:raw_value)
          .and_return(registry)
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when the parsed registry has many items' do
      let(:files) do
        version_string = version ? "version--#{version}/" : ''
        data_files     = {
          "_classes/#{version_string}rocketry.yml"               =>
            data_contents_for('Rocketry'),
          "_methods/#{version_string}rocketry/i-initialize.yml"  =>
            data_contents_for('initialize'),
          "_namespaces/#{version_string}root.yml"                =>
            data_contents_for('root')
        }

        version_string  = version ? "versions/#{version}/" : ''
        reference_files = {
          "#{version_string}reference/rocketry.md" => 'Existing reference file.'
        }

        files      = super()
        docs_files = files.fetch(docs_path, {}).merge(
          **data_files,
          **reference_files
        )

        files.merge(docs_path => docs_files)
      end
      let(:registry) do
        YARD::Registry.clear

        YARD.parse('spec/fixtures/classes/with_constructor.rb')

        items = [YARD::Registry.root, *YARD::Registry.to_a]

        SleepingKingStudios::Docs::Yard::Registry.new(items:)
      end

      after(:example) do
        YARD::Registry.clear
      end

      define_method :data_contents_for do |name| # rubocop:disable Metrics/MethodLength
        build_command = SleepingKingStudios::Docs::Yard::Build.new
        version       = defined?(self.version) ? self.version || '*' : '*'
        object        =
          registry
          .find { |object| object.name == name.to_sym }
          .then { |native| build_command.call(native).value }

        YAML.safe_dump(
          object
            .as_json
            .merge('version' => version, 'checksum' => object.checksum)
        )
      end

      context 'when there are missing files' do
        let(:files) do
          version_string = version ? "version--#{version}/" : ''
          files          = super()
          docs_files     = files.fetch(docs_path, {})

          docs_files.delete("_classes/#{version_string}rocketry.yml")

          files.merge(docs_path => docs_files)
        end
        let(:missing_files) do
          version_string = version ? "version--#{version}/" : ''

          ["#{docs_path}/_classes/#{version_string}rocketry.yml"]
        end

        it 'should return a failing result with an outdated docs error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end

        include_deferred 'should output to StandardIo'

        describe 'with docs_path: value' do
          let(:docs_path) { 'path/to/docs' }
          let(:options)   { super().merge(docs_path:) }

          it 'should return a failing result with an outdated docs error' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end

          include_deferred 'should output to StandardIo'
        end

        describe 'with version: value' do
          let(:version) { '1.12.3' }
          let(:options) { super().merge(version:) }

          it 'should return a failing result with an outdated docs error' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end

          include_deferred 'should output to StandardIo'
        end
      end

      context 'when there are matching files' do
        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_value)
        end

        include_deferred 'should output to StandardIo'

        describe 'with docs_path: value' do
          let(:docs_path) { 'path/to/docs' }
          let(:options)   { super().merge(docs_path:) }

          it 'should return a passing result' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(expected_value)
          end

          include_deferred 'should output to StandardIo'
        end

        describe 'with version: value' do
          let(:version) { '1.12.3' }
          let(:options) { super().merge(version:) }

          it 'should return a passing result' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(expected_value)
          end

          include_deferred 'should output to StandardIo'
        end
      end

      context 'when there are changed files' do
        let(:files) do
          version_string = version ? "version--#{version}/" : ''
          files          = super()
          docs_files     = files.fetch(docs_path, {})
          file_path      =
            "_methods/#{version_string}rocketry/i-initialize.yml"
          contents       =
            YAML
            .safe_load(docs_files[file_path])
            .merge('checksum' => 'D3ADB33F')
            .then { |hsh| YAML.dump(hsh) }
          docs_files     = docs_files.merge(file_path => contents)

          files.merge(docs_path => docs_files)
        end
        let(:changed_files) do
          version_string = version ? "version--#{version}/" : ''

          ["#{docs_path}/_methods/#{version_string}rocketry/i-initialize.yml"]
        end

        it 'should return a failing result with an outdated docs error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end

        include_deferred 'should output to StandardIo'

        describe 'with docs_path: value' do
          let(:docs_path) { 'path/to/docs' }
          let(:options)   { super().merge(docs_path:) }

          it 'should return a failing result with an outdated docs error' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end

          include_deferred 'should output to StandardIo'
        end

        describe 'with version: value' do
          let(:version) { '1.12.3' }
          let(:options) { super().merge(version:) }

          it 'should return a failing result with an outdated docs error' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end

          include_deferred 'should output to StandardIo'
        end
      end

      context 'when there are extra files' do
        let(:files) do
          version_string = version ? "version--#{version}/" : ''
          data_files     = {
            "_modules/#{version_string}space.yml" =>
              "---\nname: Space\nchecksum: D3ADB33F"
          }

          version_string  = version ? "versions/#{version}/" : ''
          reference_files = {
            "#{version_string}reference/space.md" => 'Extra reference file.'
          }

          files          = super()
          docs_files     = files.fetch(docs_path, {}).merge(
            **data_files,
            **reference_files
          )

          files.merge(docs_path => docs_files)
        end
        let(:extra_files) do
          data_version      = version ? "version--#{version}/" : ''
          reference_version = version ? "versions/#{version}/" : ''

          [
            "#{docs_path}/_modules/#{data_version}space.yml",
            "#{docs_path}/#{reference_version}reference/space.md"
          ]
        end

        it 'should return a failing result with an outdated docs error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end

        include_deferred 'should output to StandardIo'

        describe 'with docs_path: value' do
          let(:docs_path) { 'path/to/docs' }
          let(:options)   { super().merge(docs_path:) }

          it 'should return a failing result with an outdated docs error' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end

          include_deferred 'should output to StandardIo'
        end

        describe 'with version: value' do
          let(:version) { '1.12.3' }
          let(:options) { super().merge(version:) }

          it 'should return a failing result with an outdated docs error' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end

          include_deferred 'should output to StandardIo'
        end
      end

      context 'when there are many invalid files' do
        let(:files) do
          data_version      = version ? "version--#{version}/" : ''
          reference_version = version ? "versions/#{version}/" : ''
          data_files        = {
            "_modules/#{data_version}space.yml" =>
              "---\nname: Space\nchecksum: D3ADB33F"
          }
          reference_files = {
            "#{reference_version}reference/space.md" => 'Extra reference file.'
          }

          files             = super()
          docs_files        = files.fetch(docs_path, {}).merge(
            **data_files,
            **reference_files
          )
          file_path         =
            "_methods/#{data_version}rocketry/i-initialize.yml"
          contents          =
            YAML
            .safe_load(docs_files[file_path])
            .merge('checksum' => 'D3ADB33F')
            .then { |hsh| YAML.dump(hsh) }
          docs_files        = docs_files.merge(file_path => contents)

          docs_files.delete("_classes/#{data_version}rocketry.yml")

          files.merge(docs_path => docs_files)
        end
        let(:missing_files) do
          version_string = version ? "version--#{version}/" : ''

          ["#{docs_path}/_classes/#{version_string}rocketry.yml"]
        end
        let(:changed_files) do
          version_string = version ? "version--#{version}/" : ''

          ["#{docs_path}/_methods/#{version_string}rocketry/i-initialize.yml"]
        end
        let(:extra_files) do
          data_version      = version ? "version--#{version}/" : ''
          reference_version = version ? "versions/#{version}/" : ''

          [
            "#{docs_path}/_modules/#{data_version}space.yml",
            "#{docs_path}/#{reference_version}reference/space.md"
          ]
        end

        it 'should return a failing result with an outdated docs error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end

        include_deferred 'should output to StandardIo'

        describe 'with docs_path: value' do
          let(:docs_path) { 'path/to/docs' }
          let(:options)   { super().merge(docs_path:) }

          it 'should return a failing result with an outdated docs error' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end

          include_deferred 'should output to StandardIo'
        end

        describe 'with version: value' do
          let(:version) { '1.12.3' }
          let(:options) { super().merge(version:) }

          it 'should return a failing result with an outdated docs error' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end

          include_deferred 'should output to StandardIo'
        end
      end

      context 'when an existing file is missing a checksum' do
        let(:files) do
          version_string = version ? "version--#{version}/" : ''
          files          = super()
          docs_files     = files.fetch(docs_path, {})
          file_path      =
            "_methods/#{version_string}rocketry/i-initialize.yml"
          contents       =
            YAML
            .safe_load(docs_files[file_path])
            .tap { |hsh| hsh.delete('checksum') }
            .then { |hsh| YAML.dump(hsh) }
          docs_files     = docs_files.merge(file_path => contents)

          files.merge(docs_path => docs_files)
        end
        let(:changed_files) do
          version_string = version ? "version--#{version}/" : ''

          ["#{docs_path}/_methods/#{version_string}rocketry/i-initialize.yml"]
        end
        let(:expected_error_output) do
          version_string = version ? "version--#{version}/" : ''
          file_path      =
            "#{docs_path}/_methods/#{version_string}rocketry/i-initialize.yml"

          "Warning: file #{file_path} does not have a valid checksum\n"
        end

        include_deferred 'should output to StandardIo', with_error: true

        describe 'with docs_path: value' do
          let(:docs_path) { 'path/to/docs' }
          let(:options)   { super().merge(docs_path:) }

          it 'should return a failing result with an outdated docs error' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end

          include_deferred 'should output to StandardIo', with_error: true
        end

        describe 'with version: value' do
          let(:version) { '1.12.3' }
          let(:options) { super().merge(version:) }

          it 'should return a failing result with an outdated docs error' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end

          include_deferred 'should output to StandardIo', with_error: true
        end
      end
    end
  end
end
