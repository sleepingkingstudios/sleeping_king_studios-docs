# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/write_file'

RSpec.describe SleepingKingStudios::Yard::Commands::WriteFile do
  subject(:command) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:force)
    end
  end

  describe '#call' do
    let(:contents)  { 'Greetings, programs!' }
    let(:file_path) { 'path/to/file.txt' }
    let(:dir_path)  { File.dirname(File.expand_path(file_path)) }

    before(:example) do
      allow(File).to receive_messages(
        directory?: false,
        exist?:     false,
        file?:      false,
        write:      nil
      )

      allow(FileUtils).to receive(:mkdir_p)
    end

    def call_command
      command.call(contents:, file_path:)
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:contents, :file_path)
    end

    context 'when the file does not exist' do
      it { expect(call_command).to be_a_passing_result }

      it 'should create the directory' do
        call_command

        expect(FileUtils)
          .to have_received(:mkdir_p)
          .with(dir_path)
      end

      it 'should write the contents to the file' do
        call_command

        expect(File)
          .to have_received(:write)
          .with(File.expand_path(file_path), contents)
      end
    end

    context 'when the directory cannot be created' do
      let(:invalid_path) { File.expand_path('path') }
      let(:expected_error) do
        SleepingKingStudios::Yard::Errors::InvalidDirectory
          .new(path: invalid_path)
      end

      before(:example) do
        allow(FileUtils)
          .to receive(:mkdir_p)
          .and_raise(Errno::EEXIST, invalid_path)
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should attempt to create the directory' do
        call_command

        expect(FileUtils)
          .to have_received(:mkdir_p)
          .with(dir_path)
      end

      it 'should not write the contents to the file' do
        call_command

        expect(File).not_to have_received(:write)
      end
    end

    context 'when the file already exists' do
      let(:expected_error) do
        SleepingKingStudios::Yard::Errors::FileAlreadyExists
          .new(path: File.expand_path(file_path))
      end

      before(:example) do
        allow(File)
          .to receive(:exist?)
          .with(File.expand_path(file_path))
          .and_return(true)
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should not create the directory' do
        call_command

        expect(FileUtils).not_to have_received(:mkdir_p)
      end

      it 'should not write the contents to the file' do
        call_command

        expect(File).not_to have_received(:write)
      end

      context 'when initialized with force: true' do
        let(:constructor_options) { super().merge(force: true) }

        it { expect(call_command).to be_a_passing_result }

        it 'should create the directory' do
          call_command

          expect(FileUtils)
            .to have_received(:mkdir_p)
            .with(dir_path)
        end

        it 'should write the contents to the file' do
          call_command

          expect(File)
            .to have_received(:write)
            .with(File.expand_path(file_path), contents)
        end
      end
    end

    context 'when a directory exists at the file path' do
      let(:expected_error) do
        SleepingKingStudios::Yard::Errors::InvalidFile
          .new(path: File.expand_path(file_path))
      end

      before(:example) do
        allow(File)
          .to receive(:write)
          .and_raise(Errno::EISDIR, File.expand_path(file_path))
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should create the directory' do
        call_command

        expect(FileUtils)
          .to have_received(:mkdir_p)
          .with(dir_path)
      end

      it 'should attempt to write the contents to the file' do
        call_command

        expect(File)
          .to have_received(:write)
          .with(File.expand_path(file_path), contents)
      end
    end

    context 'when creating the directory raises an exception' do
      let(:expected_error) do
        exception = StandardError.new('something went wrong')

        Cuprum::Errors::UncaughtException.new(
          exception:,
          message:   "uncaught exception in #{described_class.name} - "
        )
      end

      before(:example) do
        allow(FileUtils)
          .to receive(:mkdir_p)
          .and_raise(StandardError, 'something went wrong')
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should attempt to create the directory' do
        call_command

        expect(FileUtils)
          .to have_received(:mkdir_p)
          .with(dir_path)
      end

      it 'should not write the contents to the file' do
        call_command

        expect(File).not_to have_received(:write)
      end
    end

    context 'when creating the file raises an exception' do
      let(:expected_error) do
        exception = StandardError.new('something went wrong')

        Cuprum::Errors::UncaughtException.new(
          exception:,
          message:   "uncaught exception in #{described_class.name} - "
        )
      end

      before(:example) do
        allow(File)
          .to receive(:write)
          .and_raise(StandardError, 'something went wrong')
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should create the directory' do
        call_command

        expect(FileUtils)
          .to have_received(:mkdir_p)
          .with(dir_path)
      end

      it 'should attempt to write the contents to the file' do
        call_command

        expect(File)
          .to have_received(:write)
          .with(File.expand_path(file_path), contents)
      end
    end
  end

  describe '#force?' do
    include_examples 'should define predicate', :force?, false

    context 'when initialized with force: false' do
      let(:constructor_options) { super().merge(force: false) }

      it { expect(command.force?).to be false }
    end

    context 'when initialized with force: true' do
      let(:constructor_options) { super().merge(force: true) }

      it { expect(command.force?).to be true }
    end
  end
end
