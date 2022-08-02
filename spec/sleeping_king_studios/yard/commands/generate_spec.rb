# frozen_string_literal: true

require 'stringio'

require 'sleeping_king_studios/yard/commands/generate'

require 'support/contracts/commands/generator_contract'

RSpec.describe SleepingKingStudios::Yard::Commands::Generate do
  include Spec::Support::Contracts::Commands

  subject(:command) { described_class.new(docs_path: docs_path, **options) }

  let(:docs_path) { 'path/to/docs' }
  let(:options)   { {} }

  include_contract 'should be a generator command'

  describe '#call' do
    shared_context 'when the parsed registry has many items' do
      let(:registry) { parse_registry }

      def parse_registry
        ::YARD::Registry.clear

        ::YARD.parse('spec/fixtures/generators/basic.rb')

        [::YARD::Registry.root, *::YARD::Registry.to_a]
      end
    end

    shared_examples 'should initialize the data commands' do
      it 'should initialize the class data command' do # rubocop:disable RSpec/ExampleLength
        command.call

        expect(SleepingKingStudios::Yard::Commands::Generators::DataGenerator)
          .to have_received(:new)
          .with(
            data_class: SleepingKingStudios::Yard::Data::ClassObject,
            data_type:  :class,
            docs_path:  docs_path,
            **command.options
          )
      end

      it 'should initialize the constant data command' do # rubocop:disable RSpec/ExampleLength
        command.call

        expect(SleepingKingStudios::Yard::Commands::Generators::DataGenerator)
          .to have_received(:new)
          .with(
            data_class: SleepingKingStudios::Yard::Data::ConstantObject,
            data_type:  :constant,
            docs_path:  docs_path,
            **command.options
          )
      end

      it 'should initialize the method data command' do # rubocop:disable RSpec/ExampleLength
        command.call

        expect(SleepingKingStudios::Yard::Commands::Generators::DataGenerator)
          .to have_received(:new)
          .with(
            data_class: SleepingKingStudios::Yard::Data::MethodObject,
            data_type:  :method,
            docs_path:  docs_path,
            **command.options
          )
      end

      it 'should initialize the module data command' do # rubocop:disable RSpec/ExampleLength
        command.call

        expect(SleepingKingStudios::Yard::Commands::Generators::DataGenerator)
          .to have_received(:new)
          .with(
            data_class: SleepingKingStudios::Yard::Data::ModuleObject,
            data_type:  :module,
            docs_path:  docs_path,
            **command.options
          )
      end

      it 'should initialize the namespace data command' do # rubocop:disable RSpec/ExampleLength
        command.call

        expect(SleepingKingStudios::Yard::Commands::Generators::DataGenerator)
          .to have_received(:new)
          .with(
            data_class: SleepingKingStudios::Yard::Data::RootObject,
            data_type:  :namespace,
            docs_path:  docs_path,
            **command.options
          )
      end
    end

    shared_examples 'should initialize the reference commands' do
      it 'should initialize the class reference command' do # rubocop:disable RSpec/ExampleLength
        command.call

        expect(
          SleepingKingStudios::Yard::Commands::Generators::ReferenceGenerator
        )
          .to have_received(:new)
          .with(
            docs_path:       docs_path,
            reference_class: SleepingKingStudios::Yard::Data::ClassObject,
            reference_type:  :class,
            **command.options
          )
      end

      it 'should initialize the module reference command' do # rubocop:disable RSpec/ExampleLength
        command.call

        expect(
          SleepingKingStudios::Yard::Commands::Generators::ReferenceGenerator
        )
          .to have_received(:new)
          .with(
            docs_path:       docs_path,
            reference_class: SleepingKingStudios::Yard::Data::ModuleObject,
            reference_type:  :module,
            **command.options
          )
      end
    end

    shared_examples 'should not generate data files' do
      it 'should not generate the class data files' do
        command.call

        expect(class_data_command).not_to have_received(:call)
      end

      it 'should not generate the constant data files' do
        command.call

        expect(constant_data_command).not_to have_received(:call)
      end

      it 'should not generate the method data files' do
        command.call

        expect(method_data_command).not_to have_received(:call)
      end

      it 'should not generate the module data files' do
        command.call

        expect(module_data_command).not_to have_received(:call)
      end
    end

    shared_examples 'should not generate reference files' do
      it 'should not generate the class reference files' do
        command.call

        expect(class_reference_command).not_to have_received(:call)
      end

      it 'should not generate the module reference files' do
        command.call

        expect(module_reference_command).not_to have_received(:call)
      end
    end

    shared_examples 'should generate the data files' do
      it 'should generate the class data files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call

        expected_classes.each do |native|
          expect(class_data_command)
            .to have_received(:call)
            .with(native: native)
        end
      end

      it 'should generate the constant data files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call

        expected_constants.each do |native|
          expect(constant_data_command)
            .to have_received(:call)
            .with(native: native)
        end
      end

      it 'should generate the method data files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call

        expected_methods.each do |native|
          expect(method_data_command)
            .to have_received(:call)
            .with(native: native)
        end
      end

      it 'should generate the module data files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call

        expected_modules.each do |native|
          expect(module_data_command)
            .to have_received(:call)
            .with(native: native)
        end
      end

      it 'should generate the root namespace data file' do
        command.call

        expect(namespace_data_command)
          .to have_received(:call)
          .with(native: expected_root)
      end
    end

    shared_examples 'should generate the reference files' do
      it 'should generate the class reference files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call

        expected_classes.each do |native|
          expect(class_reference_command)
            .to have_received(:call)
            .with(native: native)
        end
      end

      it 'should generate the module reference files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call

        expected_modules.each do |native|
          expect(module_reference_command)
            .to have_received(:call)
            .with(native: native)
        end
      end
    end

    def self.data_command(data_type) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      let(:"#{data_type}_data_command") do
        instance_double(
          SleepingKingStudios::Yard::Commands::Generators::DataGenerator,
          "#{data_type}_data_command",
          call: nil
        )
      end

      before(:example) do # rubocop:disable RSpec/ScatteredSetup
        command = send(:"#{data_type}_data_command")

        allow(SleepingKingStudios::Yard::Commands::Generators::DataGenerator)
          .to receive(:new)
          .with(hash_including(data_type: data_type))
          .and_return(command)

        allow(command).to receive(:call) do |native:|
          path = native.path.empty? ? '(root)' : native.path
          output_stream.puts "- #{path}: data"

          Cuprum::Result.new(status: :success)
        end
      end
    end

    def self.reference_command(reference_type) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      let(:"#{reference_type}_reference_command") do
        instance_double(
          SleepingKingStudios::Yard::Commands::Generators::ReferenceGenerator,
          "#{reference_type}_reference_command",
          call: Cuprum::Result.new(status: :success)
        )
      end

      before(:example) do # rubocop:disable RSpec/ScatteredSetup
        command = send(:"#{reference_type}_reference_command")

        allow(
          SleepingKingStudios::Yard::Commands::Generators::ReferenceGenerator
        )
          .to receive(:new)
          .with(hash_including(reference_type: reference_type))
          .and_return(command)

        allow(command).to receive(:call) do |native:|
          output_stream.puts "- #{native.path}: reference"

          Cuprum::Result.new(status: :success)
        end
      end
    end

    data_command :class
    data_command :constant
    data_command :method
    data_command :module
    data_command :namespace

    reference_command :class
    reference_command :module

    let(:parse_command) do
      instance_double(
        SleepingKingStudios::Yard::Commands::Parse,
        call: Cuprum::Result.new(status: :success)
      )
    end
    let(:output_stream) { StringIO.new }
    let(:registry)      { parse_registry }
    let(:expected_root) { registry.first }

    def parse_registry
      ::YARD::Registry.clear

      ::YARD.parse_string('')

      [::YARD::Registry.root]
    end

    before(:example) do # rubocop:disable RSpec/ScatteredSetup
      allow(SleepingKingStudios::Yard::Commands::Parse)
        .to receive(:new)
        .and_return(parse_command)

      allow(SleepingKingStudios::Yard::Registry)
        .to receive(:instance)
        .and_return(registry)
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:file_path)
    end

    it 'should return a passing result' do
      expect(command.call).to be_a_passing_result
    end

    it 'should run the YARD parser' do
      command.call

      expect(parse_command).to have_received(:call).with(nil)
    end

    include_examples 'should not generate data files'

    it 'should generate the root namespace data file' do
      command.call

      expect(namespace_data_command)
        .to have_received(:call)
        .with(native: expected_root)
    end

    include_examples 'should not generate reference files'

    wrap_context 'when the parsed registry has many items' do
      let(:expected_classes) do
        registry.select { |obj| obj.type == :class }
      end
      let(:expected_constants) do
        registry.select { |obj| obj.type == :constant }
      end
      let(:expected_methods) do
        registry
          .select { |obj| obj.type == :method }
          .select { |obj| obj.visibility == :public }
      end
      let(:expected_modules) do
        registry.select { |obj| obj.type == :module }
      end

      it 'should return a passing result' do
        expect(command.call).to be_a_passing_result
      end

      include_examples 'should initialize the data commands'

      include_examples 'should initialize the reference commands'

      include_examples 'should generate the data files'

      include_examples 'should generate the reference files'
    end

    context 'when the YARD parser returns a failing result' do
      let(:expected_error) do
        Cuprum::Error.new(message: 'something went wrong')
      end
      let(:error_result) do
        Cuprum::Result.new(error: expected_error)
      end

      before(:example) do
        allow(parse_command).to receive(:call).and_return(error_result)
      end

      it 'should return a failing result' do
        expect(command.call)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      include_examples 'should not generate data files'

      it 'should not generate the root namespace data file' do
        command.call

        expect(namespace_data_command).not_to have_received(:call)
      end

      include_examples 'should not generate reference files'

      wrap_context 'when the parsed registry has many items' do
        include_examples 'should not generate data files'

        include_examples 'should not generate reference files'
      end
    end

    describe 'with file_path: value' do
      let(:file_path) { 'path/to/files' }

      it 'should return a passing result' do
        expect(command.call(file_path: file_path)).to be_a_passing_result
      end

      it 'should run the YARD parser' do
        command.call(file_path: file_path)

        expect(parse_command).to have_received(:call).with(file_path)
      end
    end

    context 'when initialized with dry_run: true' do
      include_context 'when the parsed registry has many items'

      let(:options) { super().merge(dry_run: true) }

      it 'should return a passing result' do
        expect(command.call).to be_a_passing_result
      end

      include_examples 'should initialize the data commands'

      include_examples 'should initialize the reference commands'
    end

    context 'when initialized with force: true' do
      include_context 'when the parsed registry has many items'

      let(:options) { super().merge(force: true) }

      it 'should return a passing result' do
        expect(command.call).to be_a_passing_result
      end

      include_examples 'should initialize the data commands'

      include_examples 'should initialize the reference commands'
    end

    context 'when initialized with verbose: true' do
      let(:options) do
        super().merge(
          output_stream: output_stream,
          verbose:       true
        )
      end
      let(:expected) do
        <<~OUTPUT
          Generating Root Namespace:
          - (root): data
        OUTPUT
      end

      it 'should return a passing result' do
        expect(command.call).to be_a_passing_result
      end

      it 'should write the status to STDOUT' do
        expect { command.call }
          .to change(output_stream, :string)
          .to be == expected
      end

      wrap_context 'when the parsed registry has many items' do
        let(:expected) do
          <<~OUTPUT
            Generating Root Namespace:
            - (root): data

            Generating Classes:
            - TopLevelClass: data
            - TopLevelClass: reference
            - TopLevelModule::ScopedClass: data
            - TopLevelModule::ScopedClass: reference

            Generating Constants:
            - TOP_LEVEL_CONSTANT: data
            - TopLevelModule::SCOPED_CONSTANT: data

            Generating Methods:
            - #top_level_instance_method: data
            - ::top_level_class_method: data
            - TopLevelModule#scoped_instance_method: data
            - TopLevelModule.scoped_class_method: data

            Generating Modules:
            - TopLevelModule: data
            - TopLevelModule: reference
            - TopLevelModule::ScopedModule: data
            - TopLevelModule::ScopedModule: reference
          OUTPUT
        end

        it 'should write the status to STDOUT' do
          expect { command.call }
            .to change(output_stream, :string)
            .to be == expected
        end
      end
    end

    context 'when initialized with version: value' do
      include_context 'when the parsed registry has many items'

      let(:options) { super().merge(version: '1.10.101') }

      it 'should return a passing result' do
        expect(command.call).to be_a_passing_result
      end

      include_examples 'should initialize the data commands'

      include_examples 'should initialize the reference commands'
    end
  end
end
