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
