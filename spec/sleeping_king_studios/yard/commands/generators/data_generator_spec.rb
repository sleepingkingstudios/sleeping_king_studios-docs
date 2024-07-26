# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/generators/data_generator'

require 'support/contracts/commands/generator_contract'

RSpec.describe SleepingKingStudios::Yard::Commands::Generators::DataGenerator do
  include Spec::Support::Contracts::Commands

  subject(:command) { described_class.new(docs_path:, **options) }

  let(:docs_path) { 'path/to/docs' }
  let(:options)   { {} }

  include_contract 'should be a generator command'

  describe '#call' do
    let(:write_command) do
      instance_double(
        SleepingKingStudios::Yard::Commands::WriteFile,
        call: Cuprum::Result.new(status: :success)
      )
    end
    let(:data_type)   { 'constant' }
    let(:registry)    { parse_registry }
    let(:native)      { registry.find { |obj| obj.name == :GRAVITY } }
    let(:data_object) do
      SleepingKingStudios::Yard::Data::ConstantObject.new(native:)
    end
    let(:file_path) { command.file_path(data_object:) }
    let(:file_data) { YAML.dump(data_object.as_json.merge('version' => '*')) }

    def call_command
      command.call(data_object:)
    end

    def parse_registry
      YARD::Registry.clear

      YARD.parse('spec/fixtures/constants/basic.rb')

      [YARD::Registry.root, *YARD::Registry.to_a]
    end

    before(:example) do
      allow(SleepingKingStudios::Yard::Commands::WriteFile)
        .to receive(:new)
        .and_return(write_command)

      allow(SleepingKingStudios::Yard::Registry)
        .to receive(:instance)
        .and_return(registry)
    end

    after(:example) do
      YARD::Registry.clear
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:data_object, :data_type)
    end

    it { expect(call_command).to be_a_passing_result }

    it 'should initialize the writer command' do
      call_command

      expect(SleepingKingStudios::Yard::Commands::WriteFile)
        .to have_received(:new)
        .with(force: false)
    end

    it 'should write the YAML file' do
      call_command

      expect(write_command)
        .to have_received(:call)
        .with(contents: file_data, file_path:)
    end

    describe 'with data_type: value' do
      let(:data_type) { 'immutable' }
      let(:file_path) do
        command.file_path(
          data_object:,
          data_type:
        )
      end

      def call_command
        command.call(data_object:, data_type:)
      end

      it { expect(call_command).to be_a_passing_result }

      it 'should write the YAML file' do
        call_command

        expect(write_command)
          .to have_received(:call)
          .with(contents: file_data, file_path:)
      end
    end

    context 'when initialized with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it { expect(call_command).to be_a_passing_result }

      it 'should not write the YAML file' do
        call_command

        expect(write_command).not_to have_received(:call)
      end
    end

    context 'when initialized with force: true' do
      let(:options) { super().merge(force: true) }

      it { expect(call_command).to be_a_passing_result }

      it 'should initialize the writer command' do
        call_command

        expect(SleepingKingStudios::Yard::Commands::WriteFile)
          .to have_received(:new)
          .with(force: true)
      end
    end

    context 'when initialized with version: value' do
      let(:version)   { '1.10.101' }
      let(:options)   { super().merge(version:) }
      let(:file_data) do
        YAML.dump(data_object.as_json.merge('version' => version))
      end

      it { expect(call_command).to be_a_passing_result }

      it 'should write the YAML file' do
        call_command

        expect(write_command)
          .to have_received(:call)
          .with(contents: file_data, file_path:)
      end
    end

    context 'when writing the YAML file fails' do
      let(:expected_error) do
        Cuprum::Error.new(message: 'something went wrong')
      end
      let(:error_result) do
        Cuprum::Result.new(error: expected_error)
      end

      before(:example) do
        allow(write_command).to receive(:call).and_return(error_result)
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end

  describe '#file_path' do
    let(:data_object) do
      instance_double(
        SleepingKingStudios::Yard::Data::ConstantObject,
        class:     SleepingKingStudios::Yard::Data::ConstantObject,
        data_path:
      )
    end
    let(:data_path)  { 'local/file' }
    let(:data_scope) { '_constants' }
    let(:file_path)  { command.file_path(data_object:) }
    let(:expected)   { File.join(docs_path, data_scope, "#{data_path}.yml") }

    it 'should define the method' do
      expect(command)
        .to respond_to(:file_path)
        .with(0).arguments
        .and_keywords(:data_object, :data_type)
    end

    it { expect(file_path).to be == expected }

    describe 'with data_type: value' do
      let(:data_type)  { :immutable }
      let(:data_scope) { '_immutables' }
      let(:file_path) do
        command.file_path(data_object:, data_type:)
      end

      it { expect(file_path).to be == expected }
    end

    context 'when initialized with version: value' do
      let(:options) { super().merge(version: '1.10.101') }
      let(:expected) do
        File.join(
          docs_path,
          data_scope,
          "version--#{options[:version]}",
          "#{data_path}.yml"
        )
      end

      it { expect(file_path).to be == expected }

      describe 'with data_type: value' do
        let(:data_type)  { :immutable }
        let(:data_scope) { '_immutables' }
        let(:file_path) do
          command.file_path(data_object:, data_type:)
        end

        it { expect(file_path).to be == expected }
      end
    end
  end
end
