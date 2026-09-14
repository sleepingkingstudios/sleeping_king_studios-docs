# frozen_string_literal: true

require 'cuprum/cli/rspec/deferred/options_examples'

require 'sleeping_king_studios/docs/jekyll/commands/update'

require 'support/deferred/reference_examples'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Commands::Update do
  include Cuprum::Cli::RSpec::Deferred::OptionsExamples
  include Spec::Support::Deferred::ReferenceExamples

  subject(:command) { described_class.new(file_system:, standard_io:) }

  let(:file_system) { Cuprum::Cli::Dependencies::FileSystem::Mock.new }
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
    :dry_run,
    type:    :boolean,
    default: false

  include_deferred 'should define option',
    :version,
    type: :string

  include_deferred 'should implement the path helpers'

  describe '#call' do
    deferred_examples 'should call subcommand' do |subcommand, instance|
      it "should initialize #{subcommand}" do
        command.call

        expect(subcommand)
          .to have_received(:new)
          .with(file_system:, standard_io:)
      end

      it "should call #{subcommand}" do
        command.call

        resolved = instance.is_a?(Proc) ? instance_exec(&instance) : instance

        expect(resolved).to have_received(:call).with(**expected_options)
      end
    end

    let(:clobber_result) { Cuprum::Result.new }
    let(:clobber_command) do
      instance_double(Cuprum::Command, call: clobber_result)
    end
    let(:generate_result) { Cuprum::Result.new(value: expected_files) }
    let(:generate_command) do
      instance_double(Cuprum::Command, call: generate_result)
    end
    let(:expected_files)   { ['path/to/file.md', 'path/to/file.yml'] }
    let(:expected_options) { command.send(:options) }

    before(:example) do
      allow(SleepingKingStudios::Docs::Jekyll::Commands::Clobber)
        .to receive(:new)
        .and_return(clobber_command)

      allow(SleepingKingStudios::Docs::Jekyll::Commands::Generate)
        .to receive(:new)
        .and_return(generate_command)
    end

    it 'should return a passing result' do
      expect(command.call)
        .to be_a_passing_result
        .with_value(expected_files)
    end

    include_deferred 'should call subcommand',
      SleepingKingStudios::Docs::Jekyll::Commands::Clobber,
      -> { clobber_command }

    include_deferred 'should call subcommand',
      SleepingKingStudios::Docs::Jekyll::Commands::Generate,
      -> { generate_command }

    context 'when the clobber command returns a failing result' do
      let(:expected_error) do
        Cuprum::Error.new(message: 'something went wrong')
      end
      let(:clobber_result) do
        Cuprum::Result.new(error: expected_error)
      end

      it 'should return a failing result' do
        expect(command.call)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      include_deferred 'should call subcommand',
        SleepingKingStudios::Docs::Jekyll::Commands::Clobber,
        -> { clobber_command }

      it 'should not call the generate command' do
        command.call

        expect(generate_command).not_to have_received(:call)
      end
    end

    context 'when the generate command returns a failing result' do
      let(:expected_error) do
        Cuprum::Error.new(message: 'something went wrong')
      end
      let(:generate_result) do
        Cuprum::Result.new(error: expected_error)
      end

      it 'should return a failing result' do
        expect(command.call)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      include_deferred 'should call subcommand',
        SleepingKingStudios::Docs::Jekyll::Commands::Clobber,
        -> { clobber_command }

      include_deferred 'should call subcommand',
        SleepingKingStudios::Docs::Jekyll::Commands::Generate,
        -> { generate_command }
    end
  end
end
