# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/parse'

RSpec.describe SleepingKingStudios::Yard::Commands::Parse do
  subject(:command) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    before(:example) { allow(YARD).to receive(:parse) }

    it { expect(command).to be_callable.with(0..1).arguments }

    describe 'with no parameters' do
      it { expect(command.call).to be_a_passing_result }

      it 'should call YARD.parse' do
        command.call

        expect(YARD).to have_received(:parse).with(no_args)
      end
    end

    describe 'with an invalid file or directory path' do
      let(:path) { 'lib/path/to/files' }
      let(:expected_error) do
        SleepingKingStudios::Yard::Errors::FileNotFound.new(path: path)
      end

      it 'should return a failing result' do
        expect(command.call(path))
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should not call YARD.parse' do
        command.call(path)

        expect(YARD).not_to have_received(:parse)
      end
    end

    describe 'with a valid file or directory path' do
      let(:path) { 'lib/path/to/files' }

      before(:example) do
        allow(File).to receive(:exist?).with(path).and_return(true)
      end

      it { expect(command.call(path)).to be_a_passing_result }

      it 'should call YARD.parse' do
        command.call(path)

        expect(YARD).to have_received(:parse).with(path)
      end
    end
  end
end
