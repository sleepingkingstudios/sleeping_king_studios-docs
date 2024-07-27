# frozen_string_literal: true

require 'sleeping_king_studios/yard/tasks/update'

RSpec.describe SleepingKingStudios::Yard::Tasks::Update do
  subject(:task) { described_class.new }

  describe '#update' do
    shared_examples 'should call the command' do
      it 'should call the command' do
        invoke_task

        expect(mock_command).to have_received(:call)
      end
    end

    let(:command_class) { SleepingKingStudios::Yard::Commands::Generate }
    let(:mock_command) do
      instance_double(command_class, call: nil)
    end
    let(:arguments) { [] }
    let(:options)   { {} }
    let(:expected_options) do
      {
        'docs_path' => './docs',
        'dry_run'   => false,
        'force'     => true,
        'verbose'   => true
      }.merge(options)
    end
    let(:formatted_options) do
      SleepingKingStudios::Tools::Toolbelt
        .instance
        .hash_tools
        .symbolize_keys(expected_options)
    end

    before(:example) do
      allow(command_class)
        .to receive(:new)
        .with(**formatted_options)
        .and_return(mock_command)
    end

    def invoke_task
      task.invoke(:update, arguments, options)
    end

    include_examples 'should call the command'

    describe 'with --docs-path=value' do
      let(:options) { super().merge('docs_path' => 'path/to/docs') }

      include_examples 'should call the command'
    end

    describe 'with --dry-run' do
      let(:options) { super().merge('dry_run' => true) }

      include_examples 'should call the command'
    end

    describe 'with --skip-verbose' do
      let(:options) { super().merge('verbose' => false) }

      include_examples 'should call the command'
    end

    describe 'with --version=value' do
      let(:options) { super().merge('version' => '1.2.3') }

      include_examples 'should call the command'
    end
  end
end
