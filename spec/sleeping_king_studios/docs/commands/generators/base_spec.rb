# frozen_string_literal: true

require 'sleeping_king_studios/docs/commands/generators/base'

require 'support/contracts/commands/generator_contract'

RSpec.describe SleepingKingStudios::Docs::Commands::Generators::Base do
  include Spec::Support::Contracts::Commands

  subject(:command) { described_class.new(docs_path:, **options) }

  let(:docs_path) { 'path/to/docs' }
  let(:options)   { {} }

  include_contract 'should be a generator command'

  describe '#call' do
    let(:expected_error) do
      Cuprum::Errors::CommandNotImplemented.new(command:)
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
          exception:,
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
end
