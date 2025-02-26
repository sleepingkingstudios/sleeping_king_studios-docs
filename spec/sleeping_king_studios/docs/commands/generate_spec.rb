# frozen_string_literal: true

require 'stringio'

require 'sleeping_king_studios/docs/commands/generate'

require 'support/contracts/commands/generator_contract'

RSpec.describe SleepingKingStudios::Docs::Commands::Generate do
  include Spec::Support::Contracts::Commands

  subject(:command) { described_class.new(docs_path:, **options) }

  let(:docs_path) { 'path/to/docs' }
  let(:options)   { {} }

  include_contract 'should be a generator command'

  describe '#call' do
    shared_context 'when the parsed registry has many items' do
      let(:registry) { parse_registry }

      def parse_registry
        YARD::Registry.clear

        YARD.parse('spec/fixtures/generators/basic.rb')

        [YARD::Registry.root, *YARD::Registry.to_a]
      end
    end

    shared_examples 'should only generate root data file' do
      it 'should not generate the class data files' do
        data_class = SleepingKingStudios::Docs::Data::ClassObject

        command.call

        expect(data_command)
          .not_to have_received(:call)
          .with(hash_including(data_object: an_instance_of(data_class)))
      end

      it 'should not generate the constant data files' do
        data_class = SleepingKingStudios::Docs::Data::ConstantObject

        command.call

        expect(data_command)
          .not_to have_received(:call)
          .with(hash_including(data_object: an_instance_of(data_class)))
      end

      it 'should not generate the method data files' do
        data_class = SleepingKingStudios::Docs::Data::MethodObject

        command.call

        expect(data_command)
          .not_to have_received(:call)
          .with(hash_including(data_object: an_instance_of(data_class)))
      end

      it 'should not generate the module data files' do
        data_class = SleepingKingStudios::Docs::Data::ModuleObject

        command.call

        expect(data_command)
          .not_to have_received(:call)
          .with(hash_including(data_object: an_instance_of(data_class)))
      end

      it 'should generate the root namespace data file' do
        data_class = SleepingKingStudios::Docs::Data::RootObject

        command.call

        expect(data_command)
          .to have_received(:call)
          .with(data_object: an_instance_of(data_class), data_type: :namespace)
      end
    end

    shared_examples 'should not generate reference files' do
      it 'should not generate the reference files' do
        command.call

        expect(reference_command).not_to have_received(:call)
      end
    end

    shared_examples 'should generate the data files' do
      it 'should generate the class data files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call

        expected_classes.each do |native|
          expect(data_command)
            .to have_received(:call)
            .with(data_object: class_object(native:))
        end
      end

      it 'should not generate the private class data files', # rubocop:disable RSpec/ExampleLength
        :aggregate_failures \
      do
        command.call

        unexpected_classes.each do |native|
          expect(data_command)
            .not_to have_received(:call)
            .with(data_object: class_object(native:))
        end
      end

      it 'should generate the constant data files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call

        expected_constants.each do |native|
          expect(data_command)
            .to have_received(:call)
            .with(data_object: constant_object(native:))
        end
      end

      it 'should not generate the private constant data files', # rubocop:disable RSpec/ExampleLength
        :aggregate_failures \
      do
        command.call

        unexpected_constants.each do |native|
          expect(data_command)
            .not_to have_received(:call)
            .with(data_object: constant_object(native:))
        end
      end

      it 'should generate the method data files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call

        expected_methods.each do |native|
          expect(data_command)
            .to have_received(:call)
            .with(data_object: method_object(native:))
        end
      end

      it 'should not generate the method alias data files', # rubocop:disable RSpec/ExampleLength
        :aggregate_failures \
      do
        command.call

        method_aliases.each do |native|
          expect(data_command)
            .not_to have_received(:call)
            .with(data_object: method_object(native:))
        end
      end

      it 'should not generate the private method data files', # rubocop:disable RSpec/ExampleLength
        :aggregate_failures \
      do
        command.call

        unexpected_methods.each do |native|
          expect(data_command)
            .not_to have_received(:call)
            .with(data_object: method_object(native:))
        end
      end

      it 'should generate the module data files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call

        expected_modules.each do |native|
          expect(data_command)
            .to have_received(:call)
            .with(data_object: module_object(native:))
        end
      end

      it 'should not generate the private module data files', # rubocop:disable RSpec/ExampleLength
        :aggregate_failures \
      do
        command.call

        unexpected_modules.each do |native|
          expect(data_command)
            .not_to have_received(:call)
            .with(data_object: module_object(native:))
        end
      end

      it 'should generate the root namespace data file' do
        data_class = SleepingKingStudios::Docs::Data::RootObject

        command.call

        expect(data_command)
          .to have_received(:call)
          .with(data_object: an_instance_of(data_class), data_type: :namespace)
      end
    end

    shared_examples 'should generate the reference files' do
      it 'should generate the class data files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call

        expected_classes.each do |native|
          expect(reference_command)
            .to have_received(:call)
            .with(data_object: class_object(native:))
        end
      end

      it 'should generate the module reference files', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call

        expected_modules.each do |native|
          expect(reference_command)
            .to have_received(:call)
            .with(data_object: module_object(native:))
        end
      end
    end

    let(:data_command) do
      instance_double(
        SleepingKingStudios::Docs::Commands::Generators::DataGenerator,
        call:      Cuprum::Result.new(status: :success),
        file_path: nil
      )
    end
    let(:parse_command) do
      instance_double(
        SleepingKingStudios::Yard::Commands::Parse,
        call: Cuprum::Result.new(status: :success)
      )
    end
    let(:reference_command) do
      instance_double(
        SleepingKingStudios::Docs::Commands::Generators::ReferenceGenerator,
        call:      Cuprum::Result.new(status: :success),
        file_path: nil
      )
    end
    let(:output_stream) { StringIO.new }
    let(:registry)      { parse_registry }
    let(:expected_root) { registry.first }

    def class_object(native:)
      be_a(SleepingKingStudios::Docs::Data::ClassObject)
        .and(have_attributes(name: native.path))
    end

    def constant_object(native:)
      be_a(SleepingKingStudios::Docs::Data::ConstantObject)
        .and(have_attributes(name: native.path))
    end

    def method_object(native:)
      be_a(SleepingKingStudios::Docs::Data::MethodObject)
        .and(have_attributes(name: native.path))
    end

    def module_object(native:)
      be_a(SleepingKingStudios::Docs::Data::ModuleObject)
        .and(have_attributes(name: native.path))
    end

    def parse_registry
      YARD::Registry.clear

      YARD.parse_string('')

      [YARD::Registry.root]
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    before(:example) do
      allow(SleepingKingStudios::Docs::Commands::Generators::DataGenerator)
        .to receive(:new)
        .and_return(data_command)

      allow(SleepingKingStudios::Yard::Commands::Parse)
        .to receive(:new)
        .and_return(parse_command)

      allow(SleepingKingStudios::Docs::Commands::Generators::ReferenceGenerator)
        .to receive(:new)
        .and_return(reference_command)

      allow(SleepingKingStudios::Docs::Registry)
        .to receive(:instance)
        .and_return(registry)

      allow(data_command).to receive(:file_path) do |data_object:, data_type:|
        "#{tools.str.pluralize(data_type)}/#{data_object.data_path}.yml"
      end

      allow(reference_command).to receive(:file_path) do |data_object:, **_|
        "reference/#{data_object.data_path}.md"
      end
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

    it 'should initialize the data command' do
      command.call

      expect(SleepingKingStudios::Docs::Commands::Generators::DataGenerator)
        .to have_received(:new)
        .with(docs_path:, **command.options)
    end

    include_examples 'should only generate root data file'

    include_examples 'should not generate reference files'

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

      it 'should not generate data files' do
        command.call

        expect(data_command).not_to have_received(:call)
      end

      include_examples 'should not generate reference files'

      wrap_context 'when the parsed registry has many items' do
        it 'should not generate data files' do
          command.call

          expect(data_command).not_to have_received(:call)
        end

        include_examples 'should not generate reference files'
      end
    end

    context 'when writing the data files returns failing results' do
      let(:expected_error) do
        Cuprum::Error.new(message: 'something went wrong')
      end
      let(:error_result) do
        Cuprum::Result.new(error: expected_error)
      end
      let(:error_stream) { StringIO.new }
      let(:options) do
        super().merge(error_stream:)
      end
      let(:expected) do
        <<~OUTPUT
          FAILURE: unable to write file to namespaces/root.yml - Cuprum::Error: something went wrong
        OUTPUT
      end

      before(:example) do
        allow(data_command)
          .to receive(:call)
          .and_return(error_result)
      end

      it 'should write the errors to STDERR' do
        expect { command.call }
          .to change(error_stream, :string)
          .to be == expected
      end
    end

    wrap_context 'when the parsed registry has many items' do
      let(:expected_classes) do
        registry
          .select { |obj| obj.type == :class }
          .reject { |obj| obj.tags.any? { |tag| tag.tag_name == 'private' } }
      end
      let(:unexpected_classes) do
        registry
          .select { |obj| obj.type == :class }
          .select { |obj| obj.tags.any? { |tag| tag.tag_name == 'private' } }
      end
      let(:expected_constants) do
        registry
          .select { |obj| obj.type == :constant }
          .select { |obj| obj.visibility == :public }
          .reject { |obj| obj.tags.any? { |tag| tag.tag_name == 'private' } }
      end
      let(:unexpected_constants) do
        registry
          .select { |obj| obj.type == :constant }
          .select do |obj|
            obj.visibility != :public ||
              obj.tags.any? { |tag| tag.tag_name == 'private' }
          end
      end
      let(:expected_methods) do
        registry
          .select { |obj| obj.type == :method }
          .select { |obj| obj.visibility == :public }
          .reject { |obj| obj.tags.any? { |tag| tag.tag_name == 'private' } }
          .reject(&:is_alias?)
      end
      let(:unexpected_methods) do
        registry
          .select { |obj| obj.type == :method }
          .select do |obj|
            obj.visibility != :public ||
              obj.tags.any? { |tag| tag.tag_name == 'private' }
          end
      end
      let(:method_aliases) do
        registry
          .select { |obj| obj.type == :method }
          .select(&:is_alias?)
      end
      let(:expected_modules) do
        registry
          .select { |obj| obj.type == :module }
          .reject { |obj| obj.tags.any? { |tag| tag.tag_name == 'private' } }
      end
      let(:unexpected_modules) do
        registry
          .select { |obj| obj.type == :module }
          .select { |obj| obj.tags.any? { |tag| tag.tag_name == 'private' } }
      end

      it 'should return a passing result' do
        expect(command.call).to be_a_passing_result
      end

      it 'should initialize the data command' do
        command.call

        expect(SleepingKingStudios::Docs::Commands::Generators::DataGenerator)
          .to have_received(:new)
          .with(docs_path:, **command.options)
      end

      it 'should initialize the reference command' do # rubocop:disable RSpec/ExampleLength
        command.call

        expect(
          SleepingKingStudios::Docs::Commands::Generators::ReferenceGenerator
        )
          .to have_received(:new)
          .with(docs_path:, **command.options)
      end

      include_examples 'should generate the data files'

      include_examples 'should generate the reference files'

      context 'when writing the data files returns failing results' do
        let(:expected_error) do
          Cuprum::Error.new(message: 'something went wrong')
        end
        let(:error_result) do
          Cuprum::Result.new(error: expected_error)
        end
        let(:error_stream) { StringIO.new }
        let(:options) do
          super().merge(error_stream:)
        end
        let(:expected) do
          <<~OUTPUT
            FAILURE: unable to write file to namespaces/root.yml - Cuprum::Error: something went wrong
            FAILURE: unable to write file to classes/top-level-class.yml - Cuprum::Error: something went wrong
            FAILURE: unable to write file to classes/top-level-module/scoped-class.yml - Cuprum::Error: something went wrong
            FAILURE: unable to write file to constants/top-level-constant.yml - Cuprum::Error: something went wrong
            FAILURE: unable to write file to constants/top-level-module/scoped-constant.yml - Cuprum::Error: something went wrong
            FAILURE: unable to write file to methods/i-top-level-instance-method.yml - Cuprum::Error: something went wrong
            FAILURE: unable to write file to methods/c-top-level-class-method.yml - Cuprum::Error: something went wrong
            FAILURE: unable to write file to methods/top-level-module/i-scoped-instance-method.yml - Cuprum::Error: something went wrong
            FAILURE: unable to write file to methods/top-level-module/c-scoped-class-method.yml - Cuprum::Error: something went wrong
            FAILURE: unable to write file to modules/top-level-module.yml - Cuprum::Error: something went wrong
            FAILURE: unable to write file to modules/top-level-module/scoped-module.yml - Cuprum::Error: something went wrong
          OUTPUT
        end

        before(:example) do
          allow(data_command)
            .to receive(:call)
            .and_return(error_result)
        end

        it 'should write the errors to STDERR' do
          expect { command.call }
            .to change(error_stream, :string)
            .to be == expected
        end
      end

      context 'when writing the reference files returns failing results' do
        let(:expected_error) do
          Cuprum::Error.new(message: 'something went wrong')
        end
        let(:error_result) do
          Cuprum::Result.new(error: expected_error)
        end
        let(:error_stream) { StringIO.new }
        let(:options) do
          super().merge(error_stream:)
        end
        let(:expected) do
          <<~OUTPUT
            FAILURE: unable to write file to reference/top-level-class.md - Cuprum::Error: something went wrong
            FAILURE: unable to write file to reference/top-level-module/scoped-class.md - Cuprum::Error: something went wrong
            FAILURE: unable to write file to reference/top-level-module.md - Cuprum::Error: something went wrong
            FAILURE: unable to write file to reference/top-level-module/scoped-module.md - Cuprum::Error: something went wrong
          OUTPUT
        end

        before(:example) do
          allow(reference_command)
            .to receive(:call)
            .and_return(error_result)
        end

        it 'should write the errors to STDERR' do
          expect { command.call }
            .to change(error_stream, :string)
            .to be == expected
        end
      end
    end

    describe 'with file_path: value' do
      let(:file_path) { 'path/to/files' }

      it 'should return a passing result' do
        expect(command.call(file_path:)).to be_a_passing_result
      end

      it 'should run the YARD parser' do
        command.call(file_path:)

        expect(parse_command).to have_received(:call).with(file_path)
      end
    end

    context 'when initialized with dry_run: true' do
      include_context 'when the parsed registry has many items'

      let(:options) { super().merge(dry_run: true) }

      it 'should return a passing result' do
        expect(command.call).to be_a_passing_result
      end

      it 'should initialize the data command' do
        command.call

        expect(SleepingKingStudios::Docs::Commands::Generators::DataGenerator)
          .to have_received(:new)
          .with(docs_path:, **command.options)
      end

      it 'should initialize the reference command' do # rubocop:disable RSpec/ExampleLength
        command.call

        expect(
          SleepingKingStudios::Docs::Commands::Generators::ReferenceGenerator
        )
          .to have_received(:new)
          .with(docs_path:, **command.options)
      end
    end

    context 'when initialized with force: true' do
      include_context 'when the parsed registry has many items'

      let(:options) { super().merge(force: true) }

      it 'should return a passing result' do
        expect(command.call).to be_a_passing_result
      end

      it 'should initialize the data command' do
        command.call

        expect(SleepingKingStudios::Docs::Commands::Generators::DataGenerator)
          .to have_received(:new)
          .with(docs_path:, **command.options)
      end

      it 'should initialize the reference command' do # rubocop:disable RSpec/ExampleLength
        command.call

        expect(
          SleepingKingStudios::Docs::Commands::Generators::ReferenceGenerator
        )
          .to have_received(:new)
          .with(docs_path:, **command.options)
      end
    end

    context 'when initialized with verbose: true' do
      let(:options) do
        super().merge(
          output_stream:,
          verbose:       true
        )
      end
      let(:expected) do
        <<~OUTPUT
          Generating Root Namespace:
          - root namespace
            - SUCCESS: file written to namespaces/root.yml
        OUTPUT
      end

      def indent_lines(str)
        str
          .lines
          .map { |line| line.empty? ? '' : "  #{line}" }
          .join
      end

      it 'should return a passing result' do
        expect(command.call).to be_a_passing_result
      end

      it 'should write the status to STDOUT' do
        expect { command.call }
          .to change(output_stream, :string)
          .to be == expected
      end

      context 'when writing the data files returns failing results' do
        let(:expected_error) do
          Cuprum::Error.new(message: 'something went wrong')
        end
        let(:error_result) do
          Cuprum::Result.new(error: expected_error)
        end
        let(:error_stream)  { StringIO.new }
        let(:merged_stream) { StringIO.new }
        let(:options) do
          super().merge(error_stream:)
        end
        let(:expected_status) do
          <<~OUTPUT
            Generating Root Namespace:
            - root namespace
          OUTPUT
        end
        let(:expected_errors) do
          <<~OUTPUT.then { |str| indent_lines(str) }
            - FAILURE: unable to write file to namespaces/root.yml - Cuprum::Error: something went wrong
          OUTPUT
        end
        let(:expected_output) do
          <<~OUTPUT
            Generating Root Namespace:
            - root namespace
              - FAILURE: unable to write file to namespaces/root.yml - Cuprum::Error: something went wrong
          OUTPUT
        end

        before(:example) do
          allow(data_command)
            .to receive(:call)
            .and_return(error_result)

          allow(output_stream).to receive(:puts).and_wrap_original \
          do |original, str|
            original.call(str)

            merged_stream.puts(str)
          end

          allow(error_stream).to receive(:puts).and_wrap_original \
          do |original, str|
            original.call(str)

            merged_stream.puts(str)
          end
        end

        it 'should write the status to STDOUT' do
          expect { command.call }
            .to change(output_stream, :string)
            .to be == expected_status
        end

        it 'should write the errors to STDERR' do
          expect { command.call }
            .to change(error_stream, :string)
            .to be == expected_errors
        end

        it 'should write the output to STDOUT and STDERR' do
          expect { command.call }
            .to change(merged_stream, :string)
            .to be == expected_output
        end
      end

      wrap_context 'when the parsed registry has many items' do
        let(:expected) do
          <<~OUTPUT
            Generating Root Namespace:
            - root namespace
              - SUCCESS: file written to namespaces/root.yml

            Generating Classes:
            - TopLevelClass
              - SUCCESS: file written to classes/top-level-class.yml
              - SUCCESS: file written to reference/top-level-class.md
            - TopLevelModule::ScopedClass
              - SUCCESS: file written to classes/top-level-module/scoped-class.yml
              - SUCCESS: file written to reference/top-level-module/scoped-class.md

            Generating Constants:
            - TOP_LEVEL_CONSTANT
              - SUCCESS: file written to constants/top-level-constant.yml
            - TopLevelModule::SCOPED_CONSTANT
              - SUCCESS: file written to constants/top-level-module/scoped-constant.yml

            Generating Methods:
            - #top_level_instance_method
              - SUCCESS: file written to methods/i-top-level-instance-method.yml
            - ::top_level_class_method
              - SUCCESS: file written to methods/c-top-level-class-method.yml
            - TopLevelModule#scoped_instance_method
              - SUCCESS: file written to methods/top-level-module/i-scoped-instance-method.yml
            - TopLevelModule.scoped_class_method
              - SUCCESS: file written to methods/top-level-module/c-scoped-class-method.yml

            Generating Modules:
            - TopLevelModule
              - SUCCESS: file written to modules/top-level-module.yml
              - SUCCESS: file written to reference/top-level-module.md
            - TopLevelModule::ScopedModule
              - SUCCESS: file written to modules/top-level-module/scoped-module.yml
              - SUCCESS: file written to reference/top-level-module/scoped-module.md
          OUTPUT
        end

        it 'should write the status to STDOUT' do
          expect { command.call }
            .to change(output_stream, :string)
            .to be == expected
        end

        context 'when writing the data files returns failing results' do
          let(:expected_error) do
            Cuprum::Error.new(message: 'something went wrong')
          end
          let(:error_result) do
            Cuprum::Result.new(error: expected_error)
          end
          let(:error_stream)  { StringIO.new }
          let(:merged_stream) { StringIO.new }
          let(:options) do
            super().merge(error_stream:)
          end
          let(:expected_status) do
            <<~OUTPUT
              Generating Root Namespace:
              - root namespace

              Generating Classes:
              - TopLevelClass
                - SUCCESS: file written to reference/top-level-class.md
              - TopLevelModule::ScopedClass
                - SUCCESS: file written to reference/top-level-module/scoped-class.md

              Generating Constants:
              - TOP_LEVEL_CONSTANT
              - TopLevelModule::SCOPED_CONSTANT

              Generating Methods:
              - #top_level_instance_method
              - ::top_level_class_method
              - TopLevelModule#scoped_instance_method
              - TopLevelModule.scoped_class_method

              Generating Modules:
              - TopLevelModule
                - SUCCESS: file written to reference/top-level-module.md
              - TopLevelModule::ScopedModule
                - SUCCESS: file written to reference/top-level-module/scoped-module.md
            OUTPUT
          end
          let(:expected_errors) do
            <<~OUTPUT.then { |str| indent_lines(str) }
              - FAILURE: unable to write file to namespaces/root.yml - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to classes/top-level-class.yml - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to classes/top-level-module/scoped-class.yml - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to constants/top-level-constant.yml - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to constants/top-level-module/scoped-constant.yml - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to methods/i-top-level-instance-method.yml - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to methods/c-top-level-class-method.yml - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to methods/top-level-module/i-scoped-instance-method.yml - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to methods/top-level-module/c-scoped-class-method.yml - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to modules/top-level-module.yml - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to modules/top-level-module/scoped-module.yml - Cuprum::Error: something went wrong
            OUTPUT
          end
          let(:expected_output) do
            <<~OUTPUT
              Generating Root Namespace:
              - root namespace
                - FAILURE: unable to write file to namespaces/root.yml - Cuprum::Error: something went wrong

              Generating Classes:
              - TopLevelClass
                - FAILURE: unable to write file to classes/top-level-class.yml - Cuprum::Error: something went wrong
                - SUCCESS: file written to reference/top-level-class.md
              - TopLevelModule::ScopedClass
                - FAILURE: unable to write file to classes/top-level-module/scoped-class.yml - Cuprum::Error: something went wrong
                - SUCCESS: file written to reference/top-level-module/scoped-class.md

              Generating Constants:
              - TOP_LEVEL_CONSTANT
                - FAILURE: unable to write file to constants/top-level-constant.yml - Cuprum::Error: something went wrong
              - TopLevelModule::SCOPED_CONSTANT
                - FAILURE: unable to write file to constants/top-level-module/scoped-constant.yml - Cuprum::Error: something went wrong

              Generating Methods:
              - #top_level_instance_method
                - FAILURE: unable to write file to methods/i-top-level-instance-method.yml - Cuprum::Error: something went wrong
              - ::top_level_class_method
                - FAILURE: unable to write file to methods/c-top-level-class-method.yml - Cuprum::Error: something went wrong
              - TopLevelModule#scoped_instance_method
                - FAILURE: unable to write file to methods/top-level-module/i-scoped-instance-method.yml - Cuprum::Error: something went wrong
              - TopLevelModule.scoped_class_method
                - FAILURE: unable to write file to methods/top-level-module/c-scoped-class-method.yml - Cuprum::Error: something went wrong

              Generating Modules:
              - TopLevelModule
                - FAILURE: unable to write file to modules/top-level-module.yml - Cuprum::Error: something went wrong
                - SUCCESS: file written to reference/top-level-module.md
              - TopLevelModule::ScopedModule
                - FAILURE: unable to write file to modules/top-level-module/scoped-module.yml - Cuprum::Error: something went wrong
                - SUCCESS: file written to reference/top-level-module/scoped-module.md
            OUTPUT
          end

          before(:example) do
            allow(data_command)
              .to receive(:call)
              .and_return(error_result)

            allow(output_stream).to receive(:puts).and_wrap_original \
            do |original, str|
              original.call(str)

              merged_stream.puts(str)
            end

            allow(error_stream).to receive(:puts).and_wrap_original \
            do |original, str|
              original.call(str)

              merged_stream.puts(str)
            end
          end

          it 'should write the status to STDOUT' do
            expect { command.call }
              .to change(output_stream, :string)
              .to be == expected_status
          end

          it 'should write the errors to STDERR' do
            expect { command.call }
              .to change(error_stream, :string)
              .to be == expected_errors
          end

          it 'should write the output to STDOUT and STDERR' do
            expect { command.call }
              .to change(merged_stream, :string)
              .to be == expected_output
          end
        end

        context 'when writing the reference files returns failing results' do
          let(:expected_error) do
            Cuprum::Error.new(message: 'something went wrong')
          end
          let(:error_result) do
            Cuprum::Result.new(error: expected_error)
          end
          let(:error_stream)  { StringIO.new }
          let(:merged_stream) { StringIO.new }
          let(:options) do
            super().merge(error_stream:)
          end
          let(:expected_status) do
            <<~OUTPUT
              Generating Root Namespace:
              - root namespace
                - SUCCESS: file written to namespaces/root.yml

              Generating Classes:
              - TopLevelClass
                - SUCCESS: file written to classes/top-level-class.yml
              - TopLevelModule::ScopedClass
                - SUCCESS: file written to classes/top-level-module/scoped-class.yml

              Generating Constants:
              - TOP_LEVEL_CONSTANT
                - SUCCESS: file written to constants/top-level-constant.yml
              - TopLevelModule::SCOPED_CONSTANT
                - SUCCESS: file written to constants/top-level-module/scoped-constant.yml

              Generating Methods:
              - #top_level_instance_method
                - SUCCESS: file written to methods/i-top-level-instance-method.yml
              - ::top_level_class_method
                - SUCCESS: file written to methods/c-top-level-class-method.yml
              - TopLevelModule#scoped_instance_method
                - SUCCESS: file written to methods/top-level-module/i-scoped-instance-method.yml
              - TopLevelModule.scoped_class_method
                - SUCCESS: file written to methods/top-level-module/c-scoped-class-method.yml

              Generating Modules:
              - TopLevelModule
                - SUCCESS: file written to modules/top-level-module.yml
              - TopLevelModule::ScopedModule
                - SUCCESS: file written to modules/top-level-module/scoped-module.yml
            OUTPUT
          end
          let(:expected_errors) do
            <<~OUTPUT.then { |str| indent_lines(str) }
              - FAILURE: unable to write file to reference/top-level-class.md - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to reference/top-level-module/scoped-class.md - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to reference/top-level-module.md - Cuprum::Error: something went wrong
              - FAILURE: unable to write file to reference/top-level-module/scoped-module.md - Cuprum::Error: something went wrong
            OUTPUT
          end
          let(:expected_output) do
            <<~OUTPUT
              Generating Root Namespace:
              - root namespace
                - SUCCESS: file written to namespaces/root.yml

              Generating Classes:
              - TopLevelClass
                - SUCCESS: file written to classes/top-level-class.yml
                - FAILURE: unable to write file to reference/top-level-class.md - Cuprum::Error: something went wrong
              - TopLevelModule::ScopedClass
                - SUCCESS: file written to classes/top-level-module/scoped-class.yml
                - FAILURE: unable to write file to reference/top-level-module/scoped-class.md - Cuprum::Error: something went wrong

              Generating Constants:
              - TOP_LEVEL_CONSTANT
                - SUCCESS: file written to constants/top-level-constant.yml
              - TopLevelModule::SCOPED_CONSTANT
                - SUCCESS: file written to constants/top-level-module/scoped-constant.yml

              Generating Methods:
              - #top_level_instance_method
                - SUCCESS: file written to methods/i-top-level-instance-method.yml
              - ::top_level_class_method
                - SUCCESS: file written to methods/c-top-level-class-method.yml
              - TopLevelModule#scoped_instance_method
                - SUCCESS: file written to methods/top-level-module/i-scoped-instance-method.yml
              - TopLevelModule.scoped_class_method
                - SUCCESS: file written to methods/top-level-module/c-scoped-class-method.yml

              Generating Modules:
              - TopLevelModule
                - SUCCESS: file written to modules/top-level-module.yml
                - FAILURE: unable to write file to reference/top-level-module.md - Cuprum::Error: something went wrong
              - TopLevelModule::ScopedModule
                - SUCCESS: file written to modules/top-level-module/scoped-module.yml
                - FAILURE: unable to write file to reference/top-level-module/scoped-module.md - Cuprum::Error: something went wrong
            OUTPUT
          end

          before(:example) do
            allow(reference_command)
              .to receive(:call)
              .and_return(error_result)

            allow(output_stream).to receive(:puts).and_wrap_original \
            do |original, str|
              original.call(str)

              merged_stream.puts(str)
            end

            allow(error_stream).to receive(:puts).and_wrap_original \
            do |original, str|
              original.call(str)

              merged_stream.puts(str)
            end
          end

          it 'should write the status to STDOUT' do
            expect { command.call }
              .to change(output_stream, :string)
              .to be == expected_status
          end

          it 'should write the errors to STDERR' do
            expect { command.call }
              .to change(error_stream, :string)
              .to be == expected_errors
          end

          it 'should write the output to STDOUT and STDERR' do
            expect { command.call }
              .to change(merged_stream, :string)
              .to be == expected_output
          end
        end
      end
    end

    context 'when initialized with version: value' do
      include_context 'when the parsed registry has many items'

      let(:options) { super().merge(version: '1.10.101') }

      it 'should return a passing result' do
        expect(command.call).to be_a_passing_result
      end

      it 'should initialize the data command' do
        command.call

        expect(SleepingKingStudios::Docs::Commands::Generators::DataGenerator)
          .to have_received(:new)
          .with(docs_path:, **command.options)
      end

      it 'should initialize the reference command' do # rubocop:disable RSpec/ExampleLength
        command.call

        expect(
          SleepingKingStudios::Docs::Commands::Generators::ReferenceGenerator
        )
          .to have_received(:new)
          .with(docs_path:, **command.options)
      end
    end
  end
end
