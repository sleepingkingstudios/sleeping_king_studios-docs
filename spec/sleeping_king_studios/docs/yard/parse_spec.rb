# frozen_string_literal: true

require 'cuprum/cli/dependencies/file_system/mock'

require 'sleeping_king_studios/docs/yard/parse'

RSpec.describe SleepingKingStudios::Docs::Yard::Parse do
  subject(:command) { described_class.new(file_system:) }

  let(:files)       { {} }
  let(:file_system) { Cuprum::Cli::Dependencies::FileSystem::Mock.new(files:) }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    let(:root_doc) { instance_double(YARD::CodeObjects::RootObject) }
    let(:registered_docs) do
      [
        instance_double(YARD::CodeObjects::ModuleObject),
        instance_double(YARD::CodeObjects::ClassObject),
        instance_double(YARD::CodeObjects::MethodObject)
      ]
    end
    let(:expected_value) do
      [root_doc, *registered_docs]
    end

    before(:example) do
      allow(YARD).to receive(:parse)

      allow(YARD::Registry).to receive_messages(
        root: root_doc,
        to_a: registered_docs
      )
    end

    it { expect(command).to be_callable.with(0..1).arguments }

    it 'should return a passing result' do
      expect(command.call)
        .to be_a_passing_result
        .with_value(expected_value)
    end

    it 'should call YARD.parse' do
      command.call

      expect(YARD).to have_received(:parse).with(no_args)
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

    describe 'with a valid file or directory path' do
      let(:path)  { 'lib/path/to/files' }
      let(:files) { super().merge(path => {}) }

      it 'should return a passing result' do
        expect(command.call(path))
          .to be_a_passing_result
          .with_value(expected_value)
      end

      it 'should call YARD.parse' do
        command.call(path)

        expect(YARD).to have_received(:parse).with(path)
      end
    end
  end
end
