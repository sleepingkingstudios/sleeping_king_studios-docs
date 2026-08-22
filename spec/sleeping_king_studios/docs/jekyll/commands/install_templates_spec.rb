# frozen_string_literal: true

require 'cuprum/cli/rspec/deferred/options_examples'

require 'sleeping_king_studios/docs/jekyll/commands/install_templates'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Commands::InstallTemplates do
  include Cuprum::Cli::RSpec::Deferred::OptionsExamples

  subject(:command) { described_class.new(file_system:, standard_io:) }

  let(:templates_path) do
    SleepingKingStudios::Docs::Jekyll::Commands.templates_path
  end
  let(:template_files) do
    {
      'template.md' => 'Top Level Template',
      'reference'   => { 'inner.md' => 'Reference Template' }
    }
      .transform_keys { |path| File.join(templates_path, 'includes', path) }
  end
  let(:files) do
    tools.hash_tools.deep_dup(template_files)
  end
  let(:file_system) do
    Cuprum::Cli::Dependencies::FileSystem::Mock.new(files:)
  end
  let(:standard_io) do
    Cuprum::Cli::Dependencies::StandardIo::Mock.new
  end

  include_deferred 'should define option',
    :docs_path,
    type:    :string,
    default: 'docs'

  include_deferred 'should define option',
    :dry_run,
    type:    :boolean,
    default: false

  include_deferred 'should define option',
    :force,
    type:    :boolean,
    default: false

  include_deferred 'should define option',
    :ignore_existing,
    type:    :boolean,
    default: false

  include_deferred 'should define --quiet option'

  include_deferred 'should define --verbose option'

  describe '#call' do
    deferred_examples 'should copy the templates' do
      it 'should copy the templates', :aggregate_failures do
        call_command

        expected_files.each do |file_path, contents|
          expect(file_system.file?(file_path)).to be true
          expect(file_system.read_file(file_path)).to eq(contents)
        end
      end

      describe 'with dry_run: true' do
        let(:options) { super().merge(dry_run: true) }

        it 'should not update the file system' do
          expect { call_command }.not_to change(file_system, :files)
        end
      end
    end

    deferred_examples 'should output to standard IO' do
      it 'should write the output to STDOUT' do
        call_command

        expect(standard_io.output_stream.string).to eq(expected_output)
      end

      it 'should write the errors to STDERR' do
        call_command

        expect(standard_io.error_stream.string).to eq(expected_errors)
      end

      describe 'with quiet: true' do
        let(:options) { super().merge(quiet: true) }

        it 'should not write to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq('')
        end

        it 'should write the errors to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq(expected_errors)
        end
      end

      describe 'with verbose: true' do
        let(:options) { super().merge(verbose: true) }
        let(:expected_output) do
          force  = options.fetch(:force, false)
          output = "Copying template files (force=#{force})...\n\n"

          includes_path = File.join(command.docs_path, '_includes')

          expected_files.keys.sort.each do |file_path|
            template = file_path[(includes_path.size + 1)...]
            output  += "  - Copying template #{template}\n"
          end

          output
        end

        it 'should write the output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq(expected_output)
        end

        it 'should write the errors to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq(expected_errors)
        end
      end
    end

    let(:options) { {} }
    let(:expected_files) do
      file_paths = [
        'template.md',
        'reference/inner.md'
      ]

      file_paths.to_h do |path|
        [
          File.join(File.join(command.docs_path, '_includes'), path),
          file_system.read_file(File.join(templates_path, 'includes', path))
        ]
      end
    end
    let(:expected_output) do
      <<~OUTPUT
        Copying template files (force=#{options.fetch(:force, false)})...
      OUTPUT
    end
    let(:expected_errors) { '' }

    define_method :call_command do
      command.call(**options)
    end

    it 'should return a passing result' do
      expect(call_command)
        .to be_a_passing_result
        .with_value(expected_files.keys.sort)
    end

    include_deferred 'should copy the templates'

    include_deferred 'should output to standard IO'

    describe 'with docs_path: value' do
      let(:docs_path) { 'path/to/docs' }
      let(:options)   { super().merge(docs_path:) }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys.sort)
      end

      include_deferred 'should copy the templates'

      include_deferred 'should output to standard IO'
    end

    context 'when one existing template file exists' do
      let(:expected_files) do
        super().except('docs/_includes/template.md')
      end
      let(:expected_error) do
        file_path = 'docs/_includes/template.md'
        message   = "unable to write file #{file_path} - file already exists"

        Cuprum::Cli::Files::Errors::FileNotWriteable.new(
          file_path:,
          message:
        )
      end
      let(:expected_errors) do
        '  ! unable to write file docs/_includes/template.md - file already ' \
          "exists\n"
      end

      before(:example) do
        file_system.create_directory('docs/_includes', recursive: true)
        file_system.write_file(
          'docs/_includes/template.md',
          'Existing contents...'
        )
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_value(expected_files.keys)
          .and_error(expected_error)
      end

      include_deferred 'should copy the templates'

      include_deferred 'should output to standard IO'
    end

    context 'when multiple existing template files exist' do
      let(:expected_files) { {} }
      let(:expected_error) do
        file_paths = [
          'docs/_includes/reference/inner.md',
          'docs/_includes/template.md'
        ]
        errors = file_paths.map do |file_path|
          message = "unable to write file #{file_path} - file already exists"

          Cuprum::Cli::Files::Errors::FileNotWriteable.new(
            file_path:,
            message:
          )
        end
        message = 'unable to copy multiple template files'

        Cuprum::Errors::MultipleErrors.new(errors:, message:)
      end
      let(:expected_errors) do
        <<~ERRORS.each_line.map { |line| "  #{line}" }.join
          ! unable to write file docs/_includes/reference/inner.md - file already exists
          ! unable to write file docs/_includes/template.md - file already exists
        ERRORS
      end

      before(:example) do
        file_system.create_directory(
          'docs/_includes/reference',
          recursive: true
        )
        file_system.write_file(
          'docs/_includes/template.md',
          'Existing contents...'
        )
        file_system.write_file(
          'docs/_includes/reference/inner.md',
          'Existing contents...'
        )
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_value(expected_files.keys)
          .and_error(expected_error)
      end

      it 'should not update the file system' do
        expect { call_command }.not_to change(file_system, :files)
      end

      include_deferred 'should output to standard IO'
    end
  end
end
