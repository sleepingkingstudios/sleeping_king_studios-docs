# frozen_string_literal: true

require 'stringio'

require 'sleeping_king_studios/yard/commands/generators/module_generator'

require 'support/contracts/commands/generator_contract'

RSpec.describe SleepingKingStudios::Yard::Commands::Generators::ModuleGenerator do # rubocop:disable Layout/LineLength
  include Spec::Support::Contracts::Commands

  subject(:command) { described_class.new(docs_path: docs_path, **options) }

  let(:docs_path)     { 'path/to/docs' }
  let(:output_stream) { StringIO.new }
  let(:error_stream)  { StringIO.new }
  let(:options) do
    { error_stream: error_stream, output_stream: output_stream }
  end

  include_contract 'should be a generator command'

  describe '#call' do
    let(:write_command) do
      instance_double(
        SleepingKingStudios::Yard::Commands::WriteFile,
        call: Cuprum::Result.new(status: :success)
      )
    end
    let(:registry)  { parse_registry }
    let(:native)    { registry.find { |obj| obj.name == :Space } }
    let(:refs_path) { "#{docs_path}/reference" }
    let(:file_path) { "#{refs_path}/space.md" }
    let(:data_path) { "#{docs_path}/_modules" }
    let(:yaml_path) { "#{data_path}/space.yml" }
    let(:file_data) do
      <<~MARKDOWN
        ---
        data_path: "space"
        version: "*"
        ---

        {% include templates/reference/module.md %}
      MARKDOWN
    end
    let(:yaml_data) do
      <<~YAML
        ---
        name: Space
        slug: space
        files:
        - spec/fixtures/modules/basic.rb
        short_description: This module is out of this world.
        data_path: space
        version: "*"
      YAML
    end

    def parse_registry
      ::YARD::Registry.clear

      ::YARD.parse('spec/fixtures/modules/basic.rb')

      [::YARD::Registry.root, *::YARD::Registry.to_a]
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

    it 'should write the Markdown file' do
      command.call(native: native)

      expect(write_command)
        .to have_received(:call)
        .with(contents: file_data, file_path: file_path)
    end

    it 'should write the YAML file' do
      command.call(native: native)

      expect(write_command)
        .to have_received(:call)
        .with(contents: yaml_data, file_path: yaml_path)
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

      it 'should not write the Markdown or YAML files' do
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
        "- #{native.path} to #{yaml_path}\n" \
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
      let(:refs_path) { "#{docs_path}/versions/#{version}/reference" }
      let(:data_path) { "#{docs_path}/_modules/_versions/#{version}" }
      let(:file_data) do
        <<~MARKDOWN
          ---
          data_path: "space"
          version: "1.10.101"
          ---

          {% include templates/reference/module.md %}
        MARKDOWN
      end
      let(:yaml_data) do
        <<~YAML
          ---
          name: Space
          slug: space
          files:
          - spec/fixtures/modules/basic.rb
          short_description: This module is out of this world.
          data_path: space
          version: 1.10.101
        YAML
      end

      it { expect(command.call(native: native)).to be_a_passing_result }

      it 'should write the YAML file' do
        command.call(native: native)

        expect(write_command)
          .to have_received(:call)
          .with(contents: yaml_data, file_path: yaml_path)
      end

      it 'should write the Markdown file' do
        command.call(native: native)

        expect(write_command)
          .to have_received(:call)
          .with(contents: file_data, file_path: file_path)
      end
    end

    context 'when writing the Markdown file fails' do
      let(:original_error) do
        Cuprum::Error.new(message: 'something went wrong')
      end
      let(:error_result) do
        Cuprum::Result.new(error: original_error)
      end
      let(:expected_error) do
        Cuprum::Errors::MultipleErrors.new(errors: [nil, original_error])
      end
      let(:expected) do
        "- [ERROR] #{native.path} to #{file_path} - " \
          "#{original_error.class}: #{original_error.message}\n"
      end

      before(:example) do
        allow(write_command)
          .to receive(:call)
          .with(contents: file_data, file_path: file_path)
          .and_return(error_result)
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
        let(:expected) do
          "- #{native.path} to #{yaml_path}\n"
        end

        it 'should write the status to STDOUT' do
          expect { command.call(native: native) }
            .to change(output_stream, :string)
            .to be == expected
        end
      end
    end

    context 'when writing the YAML file fails' do
      let(:original_error) do
        Cuprum::Error.new(message: 'something went wrong')
      end
      let(:error_result) do
        Cuprum::Result.new(error: original_error)
      end
      let(:expected_error) do
        Cuprum::Errors::MultipleErrors.new(errors: [original_error, nil])
      end
      let(:expected) do
        "- [ERROR] #{native.path} to #{yaml_path} - " \
          "#{original_error.class}: #{original_error.message}\n"
      end

      before(:example) do
        allow(write_command)
          .to receive(:call)
          .with(contents: yaml_data, file_path: yaml_path)
          .and_return(error_result)
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
        let(:expected) do
          "- #{native.path} to #{file_path}\n"
        end

        it 'should write the status to STDOUT' do
          expect { command.call(native: native) }
            .to change(output_stream, :string)
            .to be == expected
        end
      end
    end
  end
end
