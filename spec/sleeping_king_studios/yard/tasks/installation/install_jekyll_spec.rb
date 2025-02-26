# frozen_string_literal: true

require 'sleeping_king_studios/yard/tasks/installation/install_jekyll'

RSpec.describe SleepingKingStudios::Yard::Tasks::Installation::InstallJekyll do
  subject(:task) { described_class.new }

  describe '#templates' do
    let(:docs_path) { '/path/to/docs' }
    let(:arguments) { [] }
    let(:options)   { {} }
    let(:command_class) do
      SleepingKingStudios::Docs::Commands::Installation::InstallJekyll
    end
    let(:mock_command) do
      instance_double(command_class, call: nil)
    end
    let(:expected_options) do
      {
        dry_run: false,
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
      task.invoke(:install, arguments, options.merge(docs_path:))
    end

    it { expect(task).to respond_to(:install).with(0).arguments }

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
        .with(docs_path:)
    end

    describe 'with description: value' do
      let(:options) { super().merge(description: 'A real gem.') }

      it 'should initialize the command' do
        invoke_task

        expect(command_class)
          .to have_received(:new)
          .with(**expected_options)
      end
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

    describe 'with name: value' do
      let(:options) { super().merge(name: 'Orichalcum') }

      it 'should initialize the command' do
        invoke_task

        expect(command_class)
          .to have_received(:new)
          .with(**expected_options)
      end
    end

    describe 'with repository: value' do
      let(:options) { super().merge(repository: 'Awww.example.com/orichalcum') }

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
          .with(docs_path:, root_path: '/path/to/root')
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
