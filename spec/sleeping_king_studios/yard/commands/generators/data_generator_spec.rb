# frozen_string_literal: true

require 'stringio'

require 'sleeping_king_studios/yard/commands/generators/data_generator'

require 'support/contracts/commands/generator_contract'

RSpec.describe SleepingKingStudios::Yard::Commands::Generators::DataGenerator do
  include Spec::Support::Contracts::Commands

  subject(:command) do
    described_class.new(
      data_class: data_class,
      data_type:  data_type,
      docs_path:  docs_path,
      **options
    )
  end

  let(:data_class)    { SleepingKingStudios::Yard::Data::ConstantObject }
  let(:data_type)     { :constant }
  let(:docs_path)     { 'path/to/docs' }
  let(:output_stream) { StringIO.new }
  let(:error_stream)  { StringIO.new }
  let(:options) do
    { error_stream: error_stream, output_stream: output_stream }
  end

  include_contract 'should be a generator command',
    constructor_keywords: %i[data_class data_type]

  describe '#call' do
    let(:write_command) do
      instance_double(
        SleepingKingStudios::Yard::Commands::WriteFile,
        call: Cuprum::Result.new(status: :success)
      )
    end
    let(:registry)    { parse_registry }
    let(:native)      { registry.find { |obj| obj.name == :GRAVITY } }
    let(:data_object) { data_class.new(native: native) }
    let(:data_path) do
      "#{docs_path}/_#{tools.str.pluralize(data_type.to_s)}"
    end
    let(:file_path) { "#{data_path}/#{data_object.data_path}.yml" }
    let(:file_data) { YAML.dump(data_object.as_json.merge('version' => '*')) }

    def parse_registry
      ::YARD::Registry.clear

      ::YARD.parse(
        "spec/fixtures/#{tools.str.pluralize(data_type.to_s)}/basic.rb"
      )

      [::YARD::Registry.root, *::YARD::Registry.to_a]
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
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
      ::YARD::Registry.clear
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:native)
    end

    it { expect(command.call(native: native)).to be_a_passing_result }

    it 'should initialize the writer command' do
      command.call(native: native)

      expect(SleepingKingStudios::Yard::Commands::WriteFile)
        .to have_received(:new)
        .with(force: false)
    end

    it 'should write the YAML file' do
      command.call(native: native)

      expect(write_command)
        .to have_received(:call)
        .with(contents: file_data, file_path: file_path)
    end

    it 'should not write to STDERR' do
      expect { command.call(native: native) }
        .not_to change(error_stream, :string)
    end

    it 'should not write to STDOUT' do
      expect { command.call(native: native) }
        .not_to change(output_stream, :string)
    end

    context 'when initialized with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it { expect(command.call(native: native)).to be_a_passing_result }

      it 'should not write the YAML file' do
        command.call(native: native)

        expect(write_command).not_to have_received(:call)
      end
    end

    context 'when initialized with force: true' do
      let(:options) { super().merge(force: true) }

      it { expect(command.call(native: native)).to be_a_passing_result }

      it 'should initialize the writer command' do
        command.call(native: native)

        expect(SleepingKingStudios::Yard::Commands::WriteFile)
          .to have_received(:new)
          .with(force: true)
      end
    end

    context 'when initialized with verbose: true' do
      let(:options) { super().merge(verbose: true) }
      let(:expected) do
        "- #{native.path} to #{file_path}\n"
      end

      it { expect(command.call(native: native)).to be_a_passing_result }

      it 'should not write to STDERR' do
        expect { command.call(native: native) }
          .not_to change(error_stream, :string)
      end

      it 'should write the status to STDOUT' do
        expect { command.call(native: native) }
          .to change(output_stream, :string)
          .to be == expected
      end
    end

    context 'when initialized with version: value' do
      let(:version)   { '1.10.101' }
      let(:options)   { super().merge(version: version) }
      let(:data_path) { "#{super()}/_versions/#{version}" }
      let(:file_data) do
        YAML.dump(data_object.as_json.merge('version' => version))
      end

      it { expect(command.call(native: native)).to be_a_passing_result }

      it 'should write the YAML file' do
        command.call(native: native)

        expect(write_command)
          .to have_received(:call)
          .with(contents: file_data, file_path: file_path)
      end
    end

    context 'when writing the YAML file fails' do
      let(:expected_error) do
        Cuprum::Error.new(message: 'something went wrong')
      end
      let(:error_result) do
        Cuprum::Result.new(error: expected_error)
      end
      let(:expected) do
        "- [ERROR] #{native.path} to #{file_path} - " \
          "#{expected_error.class}: #{expected_error.message}\n"
      end

      before(:example) do
        allow(write_command).to receive(:call).and_return(error_result)
      end

      it 'should return a failing result' do
        expect(command.call(native: native))
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should write the error to STDERR' do
        expect { command.call(native: native) }
          .to change(error_stream, :string)
          .to be == expected
      end

      context 'when initialized with verbose: true' do
        let(:options) { super().merge(verbose: true) }

        it 'should not write to STDOUT' do
          expect { command.call(native: native) }
            .not_to change(output_stream, :string)
        end
      end
    end
  end

  describe '#data_class' do
    include_examples 'should define reader', :data_class, -> { data_class }
  end

  describe '#data_type' do
    include_examples 'should define reader', :data_type, -> { data_type }
  end
end
