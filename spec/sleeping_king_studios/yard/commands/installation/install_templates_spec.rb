# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/installation/install_templates'

RSpec.describe \
  SleepingKingStudios::Yard::Commands::Installation::InstallTemplates \
do
  subject(:command) { described_class.new(**options) }

  let(:error_stream)  { StringIO.new }
  let(:output_stream) { StringIO.new }
  let(:options)       { { error_stream:, output_stream: } }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  describe '#call' do
    let(:docs_path) { '/path/to/docs' }
    let(:templates_path) do
      File.join(
        SleepingKingStudios::Yard.gem_path,
        'lib',
        'sleeping_king_studios',
        'yard',
        'templates',
        'includes',
        'reference'
      )
    end
    let(:templates_pattern) { File.join(templates_path, '**', '*.md') }
    let(:templates) do
      [
        "#{templates_path}/outer/inner/template.md",
        "#{templates_path}/outer/template.md",
        "#{templates_path}/template.md"
      ]
    end
    let(:expected_files) do
      templates.map do |template_file|
        template_file.sub(templates_path, "#{docs_path}/_includes/reference")
      end
    end
    let(:expected_directories) do
      expected_files.map { |filename| File.dirname(filename) }
    end
    let(:expected_output) do
      <<~OUTPUT
        Copying template files (force=false)...
          - Copying template outer/inner/template.md
          - Copying template outer/template.md
          - Copying template template.md
        Done!
      OUTPUT
    end

    before(:example) do
      allow(Dir).to receive(:[]).with(templates_pattern).and_return(templates)
      allow(File).to receive(:exist?).and_return(false)
      allow(FileUtils).to receive_messages(
        copy:    nil,
        mkdir_p: nil
      )
    end

    it 'should define the method' do
      expect(command).to be_callable.with(0).arguments.and_keywords(:docs_path)
    end

    it 'should return a passing result' do
      expect(command.call(docs_path:))
        .to be_a_passing_result
        .with_value(nil)
    end

    it 'should generate the template directories', :aggregate_failures do
      command.call(docs_path:)

      expected_directories.each do |dirname|
        expect(FileUtils).to have_received(:mkdir_p).with(dirname)
      end
    end

    it 'should copy the template files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      command.call(docs_path:)

      templates.zip(expected_files).each do |template_file, expected_file|
        expect(FileUtils)
          .to have_received(:copy)
          .with(template_file, expected_file)
      end
    end

    it 'should print the report to STDOUT' do
      command.call(docs_path:)

      expect(output_stream.string).to be == expected_output
    end

    it 'should not print to STDERR' do
      command.call(docs_path:)

      expect(error_stream.string).to be == ''
    end

    context 'when a template file already exists' do
      let(:existing_file) { expected_files[1] }
      let(:expected_error) do
        SleepingKingStudios::Yard::Errors::FileAlreadyExists
          .new(path: existing_file)
      end
      let(:expected_output) do
        <<~OUTPUT
          Copying template files (force=false)...
            - Copying template outer/inner/template.md
            - Copying template outer/template.md
        OUTPUT
      end
      let(:expected_error_output) do
        <<~OUTPUT
          Error: #{expected_error.message}
        OUTPUT
      end

      before(:example) do
        allow(File).to receive(:exist?).with(existing_file).and_return(true)
      end

      it 'should return a failing result' do
        expect(command.call(docs_path:))
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should not copy the duplicate file' do
        command.call(docs_path:)

        expect(FileUtils)
          .not_to have_received(:copy)
          .with(an_instance_of(String), existing_file)
      end

      it 'should print the partial report to STDOUT' do
        command.call(docs_path:)

        expect(output_stream.string).to be == expected_output
      end

      it 'should print the error report to STDERR' do
        command.call(docs_path:)

        expect(error_stream.string).to be == expected_error_output
      end

      context 'when initialized with force: true' do
        let(:options) { super().merge(force: true) }
        let(:expected_output) do
          <<~OUTPUT
            Copying template files (force=true)...
              - Copying template outer/inner/template.md
              - Copying template outer/template.md
              - Copying template template.md
            Done!
          OUTPUT
        end

        it 'should return a passing result' do
          expect(command.call(docs_path:))
            .to be_a_passing_result
            .with_value(nil)
        end

        it 'should generate the template directories', :aggregate_failures do
          command.call(docs_path:)

          expected_directories.each do |dirname|
            expect(FileUtils).to have_received(:mkdir_p).with(dirname)
          end
        end

        it 'should copy the template files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
          command.call(docs_path:)

          templates.zip(expected_files).each do |template_file, expected_file|
            expect(FileUtils)
              .to have_received(:copy)
              .with(template_file, expected_file)
          end
        end

        it 'should print the report to STDOUT' do
          command.call(docs_path:)

          expect(output_stream.string).to be == expected_output
        end

        it 'should not print to STDERR' do
          command.call(docs_path:)

          expect(error_stream.string).to be == ''
        end
      end
    end

    context 'when initialized with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it 'should not generate any directories' do
        command.call(docs_path:)

        expect(FileUtils).not_to have_received(:mkdir_p)
      end

      it 'should not copy any files' do
        command.call(docs_path:)

        expect(FileUtils).not_to have_received(:copy)
      end

      it 'should print the report to STDOUT' do
        command.call(docs_path:)

        expect(output_stream.string).to be == expected_output
      end
    end

    context 'when initialized with verbose: false' do
      let(:options) { super().merge(verbose: false) }

      it 'should not print to STDOUT' do
        command.call(docs_path:)

        expect(output_stream.string).to be == ''
      end

      it 'should not print to STDERR' do
        command.call(docs_path:)

        expect(error_stream.string).to be == ''
      end
    end
  end

  describe '#dry_run?' do
    include_examples 'should define predicate', :dry_run?, false

    context 'when initialized with dry_run: false' do
      let(:options) { super().merge(dry_run: false) }

      it { expect(command.dry_run?).to be false }
    end

    context 'when initialized with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it { expect(command.dry_run?).to be true }
    end
  end

  describe '#force?' do
    include_examples 'should define predicate', :force?, false

    context 'when initialized with force: false' do
      let(:options) { super().merge(force: false) }

      it { expect(command.force?).to be false }
    end

    context 'when initialized with force: true' do
      let(:options) { super().merge(force: true) }

      it { expect(command.force?).to be true }
    end
  end

  describe '#verbose?' do
    include_examples 'should define predicate', :verbose?, true

    context 'when initialized with verbose: false' do
      let(:options) { super().merge(verbose: false) }

      it { expect(command.verbose?).to be false }
    end

    context 'when initialized with verbose: true' do
      let(:options) { super().merge(verbose: true) }

      it { expect(command.verbose?).to be true }
    end
  end
end
