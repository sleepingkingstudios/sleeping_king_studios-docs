# frozen_string_literal: true

require 'cuprum/cli/rspec/deferred/options_examples'

require 'sleeping_king_studios/docs/jekyll/commands/generate'

require 'support/deferred/reference_examples'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Commands::Generate do
  include Cuprum::Cli::RSpec::Deferred::OptionsExamples
  include Spec::Support::Deferred::ReferenceExamples

  subject(:command) { described_class.new(file_system:, standard_io:) }

  let(:files)       { {} }
  let(:file_system) { Cuprum::Cli::Dependencies::FileSystem::Mock.new(files:) }
  let(:standard_io) { Cuprum::Cli::Dependencies::StandardIo::Mock.new }
  let(:options)     { {} }

  before(:example) do
    allow(SleepingKingStudios::Docs::Yard::Registry.provider)
      .to receive(:set)
      .with(
        :registry,
        an_instance_of(SleepingKingStudios::Docs::Yard::Registry)
      )
  end

  include_deferred 'should define option',
    :docs_path,
    type:    :string,
    default: 'docs'

  include_deferred 'should define option',
    :version,
    type: :string

  include_deferred 'should implement the path helpers'

  describe '#call' do
    deferred_context 'when the data directories have files' do
      let(:docs_path) { options.fetch(:docs_path, 'docs') }
      let(:version)   { options[:version] }
      let(:files) do
        {
          '_classes'           => {
            'version--1.0' => { 'space/rocket.yml' => 'name: Space::Rocket' }
          },
          '_constants'         => {
            'version--1.0' => {
              'space/gravity.yml' => 'name: Space::GRAVITY'
            }
          },
          '_methods'           => {
            'version--1.0' => {
              'space/rocket/i-launch.yml' => 'name: Space::Rocket#launch'
            }
          },
          '_modules'           => {
            'version--1.0' => { 'space.yml' => 'name: Space' }
          },
          '_namespaces'        => {
            'version--1.0' => { 'root.yml' => 'name: root' }
          },
          'reference/index.md' => 'Index file, do not delete.',
          'versions'           => {
            '1.0' => {
              'reference/index.md'        => 'Versioned index file.',
              'reference/space/rocket.md' => 'Versioned nested file.',
              'reference/space.md'        => 'Versioned top-level file.'
            }
          }
        }
          .transform_keys { |key| File.join(docs_path, key) }
      end
    end

    deferred_context 'when the parsed registry has many items' do
      let(:registry) do
        YARD::Registry.clear

        YARD.parse('spec/fixtures/generators/basic.rb')

        items = [YARD::Registry.root, *YARD::Registry.to_a]

        SleepingKingStudios::Docs::Yard::Registry.new(items:)
      end

      after(:example) do
        YARD::Registry.clear
      end
    end

    deferred_examples 'should output to STDOUT' do
      it 'should output to STDOUT' do
        call_command

        expect(standard_io.output_stream.string).to eq expected_output
      end

      it 'should not output to STDERR' do
        call_command

        expect(standard_io.error_stream.string).to eq ''
      end

      describe 'with quiet: true' do
        let(:options) { super().merge(quiet: true) }

        it 'should not output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq ''
        end

        it 'should not output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq ''
        end
      end

      describe 'with verbose: true' do
        let(:options) { super().merge(verbose: true) }

        it 'should output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq verbose_output
        end

        it 'should not output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq ''
        end
      end
    end

    let(:registry) { SleepingKingStudios::Docs::Yard::Registry::EMPTY }
    let(:parse_command) do
      instance_double(
        SleepingKingStudios::Docs::Yard::Parse,
        call: Cuprum::Result.new(value: registry)
      )
    end
    let(:expected_files) { {} }
    let(:expected_output) do
      output = +''

      expected_files.each_key do |file_path|
        output << "Generating file #{file_path}...\n"
      end

      output << "Success!\n"
    end
    let(:verbose_output) do
      output = +''

      expected_files.each do |file_path, contents|
        output << "Generating file #{file_path}...\n\n"

        output << indent(contents) << "\n"
      end

      output << "Success!\n"
    end

    define_method :call_command do
      command.call(**options)
    end

    define_method :data_contents_for do |object|
      version = defined?(self.version) ? self.version || '*' : '*'

      YAML.safe_dump(object.as_json.merge('version' => version))
    end

    define_method :data_path_for do |object|
      docs_path = defined?(self.docs_path) ? self.docs_path : 'docs'
      version   = defined?(self.version)   ? self.version   : nil
      data_type = tools.string_tools.pluralize(data_type_for(object))

      if version
        "#{docs_path}/_#{data_type}/version--#{version}/#{object.data_path}.yml"
      else
        "#{docs_path}/_#{data_type}/#{object.data_path}.yml"
      end
    end

    define_method :data_type_for do |object| # rubocop:disable Metrics/MethodLength
      case object
      when SleepingKingStudios::Docs::Data::ClassObject
        'class'
      when SleepingKingStudios::Docs::Data::ConstantObject
        'constant'
      when SleepingKingStudios::Docs::Data::MethodObject
        'method'
      when SleepingKingStudios::Docs::Data::ModuleObject
        'module'
      when SleepingKingStudios::Docs::Data::NamespaceObject
        'namespace'
      end
    end

    define_method :indent do |str|
      str
        .each_line
        .map { |line| line == "\n" ? line : "  #{line}" }
        .join
    end

    define_method :reference_contents_for do |object|
      version   = defined?(self.version) ? self.version || '*' : '*'
      data_type = data_type_for(object)

      <<~MARKDOWN
        ---
        data_path: "#{object.data_path}"
        version: "#{version}"
        ---

        {% include reference/#{data_type}.md %}
      MARKDOWN
    end

    define_method :reference_path_for do |object|
      return unless object.is_a?(SleepingKingStudios::Docs::Data::ModuleObject)

      docs_path = defined?(self.docs_path) ? self.docs_path : 'docs'
      version   = defined?(self.version)   ? self.version   : nil

      if version
        "#{docs_path}/versions/#{version}/reference/#{object.data_path}.md"
      else
        "#{docs_path}/reference/#{object.data_path}.md"
      end
    end

    before(:example) do
      allow(SleepingKingStudios::Docs::Yard::Parse)
        .to receive(:new)
        .and_return(parse_command)
    end

    it 'should return a passing result' do
      expect(call_command)
        .to be_a_passing_result
        .with_value(expected_files.keys)
    end

    it 'should run the YARD parser' do
      command.call

      expect(parse_command).to have_received(:call).with(no_args)
    end

    it 'should store the YARD registry in the provider' do
      command.call

      expect(SleepingKingStudios::Docs::Yard::Registry.provider)
        .to have_received(:set)
        .with(:registry, registry)
    end

    it 'should not update the file system' do
      expect { call_command }.not_to change(file_system, :files)
    end

    include_deferred 'should output to STDOUT'

    describe 'when initialized with docs_path: value' do
      let(:docs_path) { 'path/to/docs' }
      let(:options)   { super().merge(docs_path:) }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should not update the file system' do
        expect { call_command }.not_to change(file_system, :files)
      end

      include_deferred 'should output to STDOUT'
    end

    describe 'when initialized with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should not update the file system' do
        expect { call_command }.not_to change(file_system, :files)
      end

      include_deferred 'should output to STDOUT'
    end

    describe 'when initialized with version: value' do
      let(:version) { '1.2' }
      let(:options) { super().merge(version:) }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should not update the file system' do
        expect { call_command }.not_to change(file_system, :files)
      end

      include_deferred 'should output to STDOUT'
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

      it 'should not update the file system' do
        expect { call_command }.not_to change(file_system, :files)
      end

      it 'should not output to STDOUT' do
        call_command

        expect(standard_io.output_stream.string).to eq ''
      end

      it 'should not output to STDERR' do
        call_command

        expect(standard_io.error_stream.string).to eq ''
      end
    end

    context 'when the registry provider already has a value' do
      let(:expected_error) do
        message =
          'Plumbum::Errors::ImmutableError: unable to change immutable value ' \
          'for Plumbum::OneProvider with key "registry"'

        SleepingKingStudios::Docs::Errors::RegistryError.new(message:)
      end

      before(:example) do
        allow(SleepingKingStudios::Docs::Yard::Registry.provider)
          .to receive(:set)
          .and_call_original

        allow(SleepingKingStudios::Docs::Yard::Registry.provider)
          .to receive(:raw_value)
          .and_return(registry)
      end

      it 'should return a failing result' do
        expect(command.call)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should not update the file system' do
        expect { call_command }.not_to change(file_system, :files)
      end

      it 'should not output to STDOUT' do
        call_command

        expect(standard_io.output_stream.string).to eq ''
      end

      it 'should not output to STDERR' do
        call_command

        expect(standard_io.error_stream.string).to eq ''
      end
    end

    wrap_deferred 'when the parsed registry has many items' do
      let(:expected_files) do
        build_command = SleepingKingStudios::Docs::Yard::Build.new
        expected      =
          registry
          .map { |native| build_command.call(native).value }
          .select(&:public?)

        expected.each.with_object({}) do |object, hsh|
          data_path      = data_path_for(object)
          reference_path = reference_path_for(object)

          hsh[data_path] = data_contents_for(object)

          next unless reference_path

          hsh[reference_path] = reference_contents_for(object)
        end
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should run the YARD parser' do
        command.call

        expect(parse_command).to have_received(:call).with(no_args)
      end

      it 'should store the YARD registry in the provider' do
        command.call

        expect(SleepingKingStudios::Docs::Yard::Registry.provider)
          .to have_received(:set)
          .with(:registry, registry)
      end

      it 'should generate the files', :aggregate_failures do
        call_command

        expected_files.each do |file_path, contents|
          expect(file_system.file?(file_path)).to be true
          expect(file_system.read_file(file_path)).to eq contents
        end
      end

      include_deferred 'should output to STDOUT'

      describe 'when initialized with docs_path: value' do
        let(:docs_path) { 'path/to/docs' }
        let(:options)   { super().merge(docs_path:) }

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_files.keys)
        end

        it 'should generate the files', :aggregate_failures do
          call_command

          expected_files.each do |file_path, contents|
            expect(file_system.file?(file_path)).to be true
            expect(file_system.read_file(file_path)).to eq contents
          end
        end

        include_deferred 'should output to STDOUT'
      end

      describe 'when initialized with dry_run: true' do
        let(:options) { super().merge(dry_run: true) }

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_files.keys)
        end

        it 'should not update the file system' do
          expect { call_command }.not_to change(file_system, :files)
        end

        include_deferred 'should output to STDOUT'
      end

      describe 'when initialized with version: value' do
        let(:version) { '1.2' }
        let(:options) { super().merge(version:) }

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_files.keys)
        end

        it 'should generate the files', :aggregate_failures do
          call_command

          expected_files.each do |file_path, contents|
            expect(file_system.file?(file_path)).to be true
            expect(file_system.read_file(file_path)).to eq contents
          end
        end

        include_deferred 'should output to STDOUT'
      end

      context 'when writing the data files returns failing results' do
        let(:expected_files) do
          build_command = SleepingKingStudios::Docs::Yard::Build.new
          expected      =
            registry
            .map { |native| build_command.call(native).value }
            .select(&:public?)
            .grep_v(constant_class)

          expected.each.with_object({}) do |object, hsh|
            data_path      = data_path_for(object)
            reference_path = reference_path_for(object)

            hsh[data_path] = data_contents_for(object)

            next unless reference_path

            hsh[reference_path] = reference_contents_for(object)
          end
        end
        let(:missing_files) do
          build_command = SleepingKingStudios::Docs::Yard::Build.new

          registry
            .map { |native| build_command.call(native).value }
            .select(&:public?)
            .grep(constant_class)
            .map { |object| data_path_for(object) }
        end
        let(:expected_error) do
          build_command = SleepingKingStudios::Docs::Yard::Build.new
          message       = 'unable to generate documentation files'
          errors        =
            registry
            .map { |native| build_command.call(native).value }
            .select(&:public?)
            .grep(constant_class)
            .map do |object|
              SleepingKingStudios::Docs::Errors::FileError.new(
                message: 'something went wrong',
                path:    data_path_for(object)
              )
            end

          Cuprum::Errors::MultipleErrors.new(errors:, message:)
        end
        let(:constant_class) do
          SleepingKingStudios::Docs::Data::ConstantObject
        end
        let(:generator_class) do
          SleepingKingStudios::Docs::Jekyll::Generators::DataGenerator
        end
        let(:expected_output) do
          output = +''

          expected_files.each_key do |file_path|
            output << "Generating file #{file_path}...\n"
          end

          output
        end
        let(:expected_error_output) do
          message = 'something went wrong'
          output  = +"Failures:\n\n"

          missing_files.each do |file_path|
            output << "  - Unable to generate file #{file_path} - #{message}\n"
          end

          output << "\n"
        end

        before(:example) do
          allow(command) # rubocop:disable RSpec/SubjectStub
            .to receive(:generator_for)
            .and_wrap_original do |original, object|
              next original.call(object) unless object.is_a?(constant_class)

              error = SleepingKingStudios::Docs::Errors::FileError.new(
                message: 'something went wrong',
                path:    data_path_for(object)
              )
              result = Cuprum::Result.new(error:)

              instance_double(generator_class, call: result)
            end
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end

        it 'should generate the valid files', :aggregate_failures do
          call_command

          expected_files.each do |file_path, contents|
            expect(file_system.file?(file_path)).to be true
            expect(file_system.read_file(file_path)).to eq contents
          end
        end

        it 'should output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq expected_output
        end

        it 'should output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq expected_error_output
        end
      end
    end

    wrap_deferred 'when the data directories have files' do
      let(:registry) do
        YARD::Registry.clear

        YARD.parse('spec/fixtures/modules/basic.rb')

        items = [YARD::Registry.root, *YARD::Registry.to_a]

        SleepingKingStudios::Docs::Yard::Registry.new(items:)
      end
      let(:expected_files) do
        build_command = SleepingKingStudios::Docs::Yard::Build.new
        expected      =
          registry
          .map { |native| build_command.call(native).value }
          .select(&:public?)

        expected.each.with_object({}) do |object, hsh|
          data_path      = data_path_for(object)
          reference_path = reference_path_for(object)

          hsh[data_path] = data_contents_for(object)

          next unless reference_path

          hsh[reference_path] = reference_contents_for(object)
        end
      end

      after(:example) do
        YARD::Registry.clear
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(expected_files.keys)
      end

      it 'should run the YARD parser' do
        command.call

        expect(parse_command).to have_received(:call).with(no_args)
      end

      it 'should store the YARD registry in the provider' do
        command.call

        expect(SleepingKingStudios::Docs::Yard::Registry.provider)
          .to have_received(:set)
          .with(:registry, registry)
      end

      it 'should generate the files', :aggregate_failures do
        call_command

        expected_files.each do |file_path, contents|
          expect(file_system.file?(file_path)).to be true
          expect(file_system.read_file(file_path)).to eq contents
        end
      end

      include_deferred 'should output to STDOUT'

      context 'when the data directories have directories' do
        let(:directory_paths) do
          [
            "#{docs_path}/_classes/space/oddities",
            "#{docs_path}/_constants/space/oddities",
            "#{docs_path}/_methods/space/oddities",
            "#{docs_path}/reference/space/oddities"
          ]
        end
        let(:files) do
          super().merge(directory_paths.to_h { |path| [path, {}] })
        end

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(expected_files.keys)
        end

        it 'should clean up the extra directories', :aggregate_failures do
          call_command

          directory_paths.each do |path|
            expect(file_system.directory?(path)).to be false
          end
        end

        it 'should generate the files', :aggregate_failures do
          call_command

          expected_files.each do |file_path, contents|
            expect(file_system.file?(file_path)).to be true
            expect(file_system.read_file(file_path)).to eq contents
          end
        end

        include_deferred 'should output to STDOUT'

        describe 'with dry_run: true' do
          let(:options) { super().merge(dry_run: true) }

          it 'should return a passing result' do
            expect(call_command)
              .to be_a_passing_result
              .with_value(expected_files.keys)
          end

          it 'should not update the file system' do
            expect { call_command }.not_to change(file_system, :files)
          end

          include_deferred 'should output to STDOUT'
        end
      end

      context 'when the data directories have data files' do
        let(:files) do
          super().merge(
            "#{docs_path}/_classes/space/oddity.yml" => 'Existing file...'
          )
        end
        let(:expected_error) do
          path    = "#{docs_path}/_classes/space"
          message =
            "unable to delete directory #{path} - directory is not empty"

          SleepingKingStudios::Docs::Errors::FileError.new(message:, path:)
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_value(nil)
            .and_error(expected_error)
        end

        it 'should not update the file system' do
          expect { call_command }.not_to change(file_system, :files)
        end

        it 'should not output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq ''
        end

        it 'should not output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq ''
        end

        describe 'with dry_run: true' do
          let(:options) { super().merge(dry_run: true) }

          it 'should return a failing result' do
            expect(call_command)
              .to be_a_failing_result
              .with_value(nil)
              .and_error(expected_error)
          end

          it 'should not update the file system' do
            expect { call_command }.not_to change(file_system, :files)
          end

          it 'should not output to STDOUT' do
            call_command

            expect(standard_io.output_stream.string).to eq ''
          end

          it 'should not output to STDERR' do
            call_command

            expect(standard_io.error_stream.string).to eq ''
          end
        end
      end

      context 'when the data directories have reference files' do
        let(:files) do
          super().merge(
            "#{docs_path}/reference/space/oddity.md" => 'Existing file...'
          )
        end
        let(:expected_error) do
          path    = "#{docs_path}/reference/space"
          message =
            "unable to delete directory #{path} - directory is not empty"

          SleepingKingStudios::Docs::Errors::FileError.new(message:, path:)
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_value(nil)
            .and_error(expected_error)
        end

        it 'should not update the file system' do
          expect { call_command }.not_to change(file_system, :files)
        end

        it 'should not output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq ''
        end

        it 'should not output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq ''
        end

        describe 'with dry_run: true' do
          let(:options) { super().merge(dry_run: true) }

          it 'should return a failing result' do
            expect(call_command)
              .to be_a_failing_result
              .with_value(nil)
              .and_error(expected_error)
          end

          it 'should not update the file system' do
            expect { call_command }.not_to change(file_system, :files)
          end

          it 'should not output to STDOUT' do
            call_command

            expect(standard_io.output_stream.string).to eq ''
          end

          it 'should not output to STDERR' do
            call_command

            expect(standard_io.error_stream.string).to eq ''
          end
        end
      end
    end
  end
end
