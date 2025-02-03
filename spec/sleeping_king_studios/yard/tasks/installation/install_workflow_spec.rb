# frozen_string_literal: true

require 'sleeping_king_studios/yard/tasks/installation/install_workflow'

RSpec.describe \
  SleepingKingStudios::Yard::Tasks::Installation::InstallWorkflow \
do
  subject(:task) { described_class.new }

  describe '#workflow' do
    let(:root_path) { Dir.pwd }
    let(:arguments) { [] }
    let(:options)   { {} }
    let(:command_class) do
      SleepingKingStudios::Yard::Commands::Installation::InstallWorkflow
    end
    let(:mock_command) do
      instance_double(command_class, call: nil)
    end
    let(:expected_options) do
      {
        dry_run: false,
        force:   false,
        verbose: true
      }
        .merge(options)
        .tap { |hsh| hsh.delete(:root_path) }
    end

    before(:example) do
      allow(command_class)
        .to receive(:new)
        .and_return(mock_command)
    end

    define_method :invoke_task do
      task.invoke(:workflow, arguments, options)
    end

    it { expect(task).to respond_to(:workflow).with(0).arguments }

    it 'should initialize the command' do
      invoke_task

      expect(command_class)
        .to have_received(:new)
        .with(**expected_options)
    end

    it 'should call the command' do
      invoke_task

      expect(mock_command)
        .to have_received(:call)
        .with(no_args)
    end

    describe 'with dry_run: false' do
      let(:options) { super().merge(dry_run: false) }

      it 'should initialize the command' do
        invoke_task

        expect(command_class)
          .to have_received(:new)
          .with(**expected_options)
      end
    end

    describe 'with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it 'should initialize the command' do
        invoke_task

        expect(command_class)
          .to have_received(:new)
          .with(**expected_options)
      end
    end

    describe 'with force: false' do
      let(:options) { super().merge(force: false) }

      it 'should initialize the command' do
        invoke_task

        expect(command_class)
          .to have_received(:new)
          .with(**expected_options)
      end
    end

    describe 'with force: true' do
      let(:options) { super().merge(force: true) }

      it 'should initialize the command' do
        invoke_task

        expect(command_class)
          .to have_received(:new)
          .with(**expected_options)
      end
    end

    describe 'with root_path: value' do
      let(:options) { super().merge(root_path: '/path/to/root') }

      it 'should initialize the command' do
        invoke_task

        expect(command_class)
          .to have_received(:new)
          .with(**expected_options)
      end

      it 'should call the command' do
        invoke_task

        expect(mock_command)
          .to have_received(:call)
          .with(root_path: '/path/to/root')
      end
    end

    describe 'with verbose: false' do
      let(:options) { super().merge(verbose: false) }

      it 'should initialize the command' do
        invoke_task

        expect(command_class)
          .to have_received(:new)
          .with(**expected_options)
      end
    end

    describe 'with verbose: true' do
      let(:options) { super().merge(verbose: true) }

      it 'should initialize the command' do
        invoke_task

        expect(command_class)
          .to have_received(:new)
          .with(**expected_options)
      end
    end
  end
end
