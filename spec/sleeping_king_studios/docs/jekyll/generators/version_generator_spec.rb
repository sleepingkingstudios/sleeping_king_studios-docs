# frozen_string_literal: true

require 'cuprum/cli/rspec/deferred/generators_examples'
require 'cuprum/cli/rspec/deferred/options_examples'

require 'sleeping_king_studios/docs/jekyll/generators/version_generator'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Generators::VersionGenerator \
do
  include Cuprum::Cli::RSpec::Deferred::GeneratorsExamples
  include Cuprum::Cli::RSpec::Deferred::OptionsExamples

  subject(:generator) do
    described_class.new(file_system:, standard_io:, **options)
  end

  let(:file_system) { Cuprum::Cli::Dependencies::FileSystem::Mock.new }
  let(:standard_io) { Cuprum::Cli::Dependencies::StandardIo::Mock.new }
  let(:version)     { '0.10' }
  let(:options)     { { version: } }
  let(:expected_contents) do
    <<~YAML
      ---
      version: "0.10"
      sortable: "000.010"
    YAML
  end

  include_deferred 'should define option',
    :docs_path,
    type:    :string,
    default: 'docs'

  include_deferred 'should define option',
    :version,
    type:     :string,
    required: true

  include_deferred 'should output file',
    '%<docs_path>s/_versions/%<version_slug>s.yml'

  describe '#sortable_version' do
    include_examples 'should define reader', :sortable_version, '000.010'

    context 'when initialized with a version with non-numeric values' do
      let(:version) { '2.10.3.patch.123' }

      it { expect(generator.sortable_version).to eq('002.010.003.patch.123') }
    end
  end

  describe '#version_slug' do
    include_examples 'should define reader', :version_slug, '0-10'

    context 'when initialized with a version with non-numeric values' do
      let(:version) { '2.10.3.patch.123' }

      it { expect(generator.version_slug).to eq('2-10-3-patch-123') }
    end
  end
end
