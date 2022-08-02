# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/generators/base'

require 'support/contracts/commands/generator_contract'

RSpec.describe SleepingKingStudios::Yard::Commands::Generators::Base do
  include Spec::Support::Contracts::Commands

  subject(:command) { described_class.new(docs_path: docs_path, **options) }

  let(:docs_path) { 'path/to/docs' }
  let(:options)   { {} }

  include_contract 'should be a generator command'

  describe '#call' do
    let(:expected_error) do
      Cuprum::Errors::CommandNotImplemented.new(command: command)
    end

    it { expect(command).to be_callable.with(0).arguments }

    it 'should return a failing result' do
      expect(command.call)
        .to be_a_failing_result
        .with_error(expected_error)
    end

    context 'when the implementation raises an exception' do
      let(:exception) { StandardError.new('something went wrong') }
      let(:expected_error) do
        Cuprum::Errors::UncaughtException.new(
          exception: exception,
          message:   "uncaught exception in #{described_class} - "
        )
      end

      before(:example) do
        allow(command) # rubocop:disable RSpec/SubjectStub
          .to receive(:process)
          .and_raise(exception)
      end

      it 'should return a failing result' do
        expect(command.call)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end

  describe '#puts' do
    let(:string)   { 'Greetings, starfighter!' }
    let(:expected) { "Greetings, starfighter!\n" }

    it { expect(command).to respond_to(:puts).with(1).argument }

    it 'should write the string to STDOUT' do
      expect { command.puts(string) }
        .to output(expected)
        .to_stdout
    end

    context 'when initialized with a custom output stream' do
      let(:output_stream) { StringIO.new }
      let(:options)       { super().merge(output_stream: output_stream) }

      it 'should write the string to the stream' do
        expect { command.puts(string) }
          .to change(output_stream, :string)
          .to be == expected
      end
    end
  end

  describe '#print' do
    let(:string) { '> ' }

    it { expect(command).to respond_to(:print).with(1).argument }

    it 'should write the string to STDOUT' do
      expect { command.print(string) }
        .to output(string)
        .to_stdout
    end

    context 'when initialized with a custom output stream' do
      let(:output_stream) { StringIO.new }
      let(:options)       { super().merge(output_stream: output_stream) }

      it 'should write the string to the stream' do
        expect { command.print(string) }
          .to change(output_stream, :string)
          .to be == string
      end
    end
  end

  describe '#report' do
    let(:message)       { 'Greetings, starfighter!' }
    let(:error_stream)  { StringIO.new }
    let(:output_stream) { StringIO.new }
    let(:options) do
      super().merge(error_stream: error_stream, output_stream: output_stream)
    end

    it 'should define the private method' do
      expect(command)
        .to respond_to(:report, true)
        .with(0).arguments
        .and_keywords(:message, :result)
    end

    describe 'with a passing result' do
      let(:result)   { Cuprum::Result.new }
      let(:expected) { "- #{message}\n" }

      it 'should not output to STDERR' do
        expect { command.send(:report, message: message, result: result) }
          .not_to change(error_stream, :string)
      end

      it 'should not output to STDOUT' do
        expect { command.send(:report, message: message, result: result) }
          .not_to change(output_stream, :string)
      end

      context 'when initialized with verbose: true' do
        let(:options) { super().merge(verbose: true) }

        it 'should print the message to STDOUT' do
          expect { command.send(:report, message: message, result: result) }
            .to change(output_stream, :string)
            .to be == expected
        end
      end
    end

    describe 'with a failing result' do
      let(:result)   { Cuprum::Result.new(status: :failure) }
      let(:expected) { "- [ERROR] #{message} - unable to generate file\n" }

      it 'should print the message to STDERR' do
        expect { command.send(:report, message: message, result: result) }
          .to change(error_stream, :string)
          .to be == expected
      end

      it 'should not output to STDOUT' do
        expect { command.send(:report, message: message, result: result) }
          .not_to change(output_stream, :string)
      end
    end

    describe 'with a failing result with an error' do
      let(:error)  { Cuprum::Error.new(message: 'something went wrong') }
      let(:result) { Cuprum::Result.new(error: error) }
      let(:expected) do
        "- [ERROR] #{message} - #{error.class}: #{error.message}\n"
      end

      it 'should print the message to STDERR' do
        expect { command.send(:report, message: message, result: result) }
          .to change(error_stream, :string)
          .to be == expected
      end

      it 'should not output to STDOUT' do
        expect { command.send(:report, message: message, result: result) }
          .not_to change(output_stream, :string)
      end
    end
  end

  describe '#warn' do
    let(:string)   { 'End of line.' }
    let(:expected) { "End of line.\n" }

    it { expect(command).to respond_to(:warn).with(1).argument }

    it 'should write the string to STDERR' do
      expect { command.warn(string) }
        .to output(expected)
        .to_stderr
    end

    context 'when initialized with a custom error stream' do
      let(:error_stream) { StringIO.new }
      let(:options)      { super().merge(error_stream: error_stream) }

      it 'should write the string to the stream' do
        expect { command.warn(string) }
          .to change(error_stream, :string)
          .to be == expected
      end
    end
  end
end
