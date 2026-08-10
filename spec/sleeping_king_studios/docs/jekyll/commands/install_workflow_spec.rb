# frozen_string_literal: true

require 'cuprum/cli/rspec/deferred/generators_examples'
require 'cuprum/cli/rspec/deferred/options_examples'

require 'sleeping_king_studios/docs/jekyll/commands/install_workflow'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Commands::InstallWorkflow do
  include Cuprum::Cli::RSpec::Deferred::OptionsExamples

  subject(:command) { described_class.new(file_system:, standard_io:) }

  let(:template_path) do
    File.join(
      SleepingKingStudios::Docs.gem_path,
      'lib',
      'sleeping_king_studios',
      'docs',
      'templates',
      'deploy-pages.yml.erb'
    )
  end
  let(:files) { { template_path => File.read(template_path) } }
  let(:file_system) do
    Cuprum::Cli::Dependencies::FileSystem::Mock.new(files:)
  end
  let(:standard_io) do
    Cuprum::Cli::Dependencies::StandardIo::Mock.new
  end

  describe '::Generator' do
    include Cuprum::Cli::RSpec::Deferred::GeneratorsExamples

    subject(:generator) do
      described_class.new(
        file_path,
        file_system:,
        standard_io:,
        **options
      )
    end

    let(:described_class) { super()::Generator }
    let(:file_path)       { '.github/workflows/deploy-pages.yml' }
    let(:options)         { {} }

    include_deferred 'should define option',
      :ruby_version,
      type: :string

    include_deferred 'should output file',
      '%<file_path>s',
      template: -> { template_path }
  end

  include_deferred 'should define option',
    :dry_run,
    type:    :boolean,
    default: false

  include_deferred 'should define option',
    :file_path,
    type:    :string,
    default: '.github/workflows/deploy-pages.yml'

  include_deferred 'should define option',
    :ruby_version,
    default: -> { RUBY_VERSION.split('.')[..1].join('.') },
    type:    :string

  include_deferred 'should define --quiet option'

  include_deferred 'should define --verbose option'

  describe '#call' do
    let(:file_path) { '.github/workflows/deploy-pages.yml' }
    let(:expected_contents) do
      Cuprum::Cli::Files::Engines::RenderErb
        .new
        .call(
          file_system.read(template_path),
          ruby_version: command.ruby_version
        )
        .value
    end
    let(:options) { {} }

    define_method :call_command do
      command.call(**options)
    end

    it 'should return a passing result' do
      expect(call_command)
        .to be_a_passing_result
        .with_value([file_path])
    end

    it 'should generate the file', :aggregate_failures do
      expect { call_command }.to(
        change { file_system.file?(file_path) }.to(be true)
      )

      expect(file_system.read(file_path)).to eq(expected_contents)
    end

    describe 'with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it 'should not generate the file' do
        expect { call_command }.not_to(
          change { file_system.file?(file_path) }
        )
      end
    end

    describe 'with file_path: value' do
      let(:file_path) { 'path/to/workflows/deploy-pages.yml' }
      let(:options)   { super().merge(file_path:) }

      it 'should generate the file', :aggregate_failures do
        expect { call_command }.to(
          change { file_system.file?(file_path) }.to(be true)
        )

        expect(file_system.read(file_path)).to eq(expected_contents)
      end
    end
  end
end
