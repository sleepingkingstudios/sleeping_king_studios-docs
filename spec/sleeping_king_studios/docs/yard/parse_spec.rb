# frozen_string_literal: true

require 'sleeping_king_studios/docs/yard/parse'

RSpec.describe SleepingKingStudios::Docs::Yard::Parse do
  subject(:command) { described_class.new(file_system:) }

  let(:files)       { {} }
  let(:file_system) { Cuprum::Cli::Dependencies::FileSystem::Mock.new(files:) }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    let(:items) do
      Array.new(3) { instance_double(YARD::CodeObjects::Base) }
    end
    let(:expected_value) do
      SleepingKingStudios::Docs::Yard::Registry.new(items:)
    end

    before(:example) do
      allow(YARD).to receive(:parse)

      root, *rest = items

      allow(YARD::Registry).to receive_messages(root:, to_a: rest)
    end

    it { expect(command).to be_callable.with(0..1).arguments }

    describe 'with no parameters' do
      it 'should return a passing result' do
        expect(command.call)
          .to be_a_passing_result
          .with_value(expected_value)
      end

      it 'should call YARD.parse' do
        command.call

        expect(YARD).to have_received(:parse).with(no_args)
      end
    end

    describe 'with an invalid file or directory path' do
      let(:path) { 'lib/path/to/files' }
      let(:expected_error) do
        SleepingKingStudios::Docs::Errors::FileNotFound.new(path:)
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

    describe 'with a valid directory path' do
      let(:path)  { 'lib/path/to/files' }
      let(:files) { super().merge(path => { 'file.rb' => 'puts "Hello"' }) }

      it { expect(command.call(path)).to be_a_passing_result }

      it 'should call YARD.parse' do
        command.call(path)

        expect(YARD).to have_received(:parse).with(path)
      end
    end

    describe 'with a valid file path' do
      let(:path)  { 'lib/path/to/file.rb' }
      let(:files) { super().merge(path => 'puts "Hello"') }

      it { expect(command.call(path)).to be_a_passing_result }

      it 'should call YARD.parse' do
        command.call(path)

        expect(YARD).to have_received(:parse).with(path)
      end
    end
  end
end
