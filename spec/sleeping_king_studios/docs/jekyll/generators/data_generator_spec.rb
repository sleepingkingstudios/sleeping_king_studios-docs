# frozen_string_literal: true

require 'cuprum/cli/rspec/deferred/options_examples'

require 'sleeping_king_studios/docs/jekyll/generators/data_generator'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Generators::DataGenerator do
  include Cuprum::Cli::RSpec::Deferred::OptionsExamples

  subject(:generator) do
    described_class.new(file_system:, standard_io:, **options)
  end

  let(:files) { {} }
  let(:file_system) do
    Cuprum::Cli::Dependencies::FileSystem::Mock.new(files:)
  end
  let(:standard_io) do
    Cuprum::Cli::Dependencies::StandardIo::Mock.new
  end
  let(:object) do
    mock_data(
      SleepingKingStudios::Docs::Data::RootObject,
      name: 'root'
    )
  end
  let(:options) { { object: } }

  define_method :mock_data do |data_class, name:, **params| # rubocop:disable Metrics/MethodLength
    data_path =
      name
      .split('::')
      .map { |str| tools.string_tools.underscore(str).tr('_', '-') }
      .join('/')

    instance_double(
      data_class,
      as_json:   { 'name' => name },
      class:     data_class,
      data_path:,
      name:,
      **params
    ).tap do |mock|
      allow(mock).to receive(:is_a?) { |expected| data_class <= expected }
    end
  end

  include_deferred 'should define option',
    :docs_path,
    type:    :string,
    default: 'docs'

  include_deferred 'should define option',
    :object,
    type:     SleepingKingStudios::Docs::Data::Base,
    required: true

  include_deferred 'should define option',
    :version,
    type: :string

  include_deferred 'should define --quiet option'

  include_deferred 'should define --verbose option'

  describe '#call' do
    deferred_examples 'should write the output' do
      it 'should write the output to STDOUT' do
        generator.call

        expect(standard_io.output_stream.string).to eq(expected_output)
      end

      it 'should not write to STDERR' do
        generator.call

        expect(standard_io.error_stream.string).to eq('')
      end

      context 'when initialized with quiet: true' do
        let(:options) { super().merge(quiet: true) }

        it 'should not write to STDOUT' do
          generator.call

          expect(standard_io.output_stream.string).to eq('')
        end

        it 'should not write to STDERR' do
          generator.call

          expect(standard_io.error_stream.string).to eq('')
        end
      end

      context 'when initialized with verbose: true' do
        let(:options) { super().merge(verbose: true) }

        it 'should not write to STDOUT' do
          generator.call

          expect(standard_io.output_stream.string).to eq(verbose_output)
        end

        it 'should not write to STDERR' do
          generator.call

          expect(standard_io.error_stream.string).to eq('')
        end
      end
    end

    let(:docs_path) { 'docs' }
    let(:data_file) { "#{docs_path}/_namespaces/root.yml" }
    let(:data_contents) do
      <<~YAML
        ---
        name: #{object.name}
        version: "*"
      YAML
    end
    let(:expected_output) do
      <<~OUTPUT
        Generating file #{data_file}...
      OUTPUT
    end
    let(:verbose_output) do
      <<~OUTPUT
        Generating file #{data_file}...

          ---
          name: #{object.name}
          version: "*"

      OUTPUT
    end

    it 'should return a passing result' do
      expect(generator.call)
        .to be_a_passing_result
        .with_value([data_file])
    end

    it 'should generate the data file', :aggregate_failures do
      expect { generator.call }.to(
        change { file_system.file?(data_file) }.to(be true)
      )

      expect(file_system.read(data_file)).to eq(data_contents)
    end

    include_deferred 'should write the output'

    context 'when initialized with docs_path: value' do
      let(:docs_path) { 'path/to/docs' }
      let(:options)   { super().merge(docs_path:) }

      it 'should return a passing result' do
        expect(generator.call)
          .to be_a_passing_result
          .with_value([data_file])
      end

      it 'should generate the data file', :aggregate_failures do
        expect { generator.call }.to(
          change { file_system.file?(data_file) }.to(be true)
        )

        expect(file_system.read(data_file)).to eq(data_contents)
      end

      include_deferred 'should write the output'
    end

    context 'when initialized with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it 'should return a passing result' do
        expect(generator.call)
          .to be_a_passing_result
          .with_value([data_file])
      end

      it 'should not change the file_system' do
        expect { generator.call }.not_to change(file_system, :files)
      end

      include_deferred 'should write the output'
    end

    context 'when initialized with version: value' do
      let(:version) { '1.2.3' }
      let(:options) { super().merge(version:) }
      let(:data_file) do
        "#{docs_path}/_namespaces/version--#{version}/root.yml"
      end
      let(:data_contents) do
        <<~YAML
          ---
          name: #{object.name}
          version: #{version}
        YAML
      end
      let(:verbose_output) do
        <<~OUTPUT
          Generating file #{data_file}...

            ---
            name: #{object.name}
            version: #{version}

        OUTPUT
      end

      it 'should return a passing result' do
        expect(generator.call)
          .to be_a_passing_result
          .with_value([data_file])
      end

      it 'should generate the data file', :aggregate_failures do
        expect { generator.call }.to(
          change { file_system.file?(data_file) }.to(be true)
        )

        expect(file_system.read(data_file)).to eq(data_contents)
      end

      include_deferred 'should write the output'
    end

    describe 'with a constant object' do
      let(:object) do
        mock_data(
          SleepingKingStudios::Docs::Data::ConstantObject,
          name: 'Space::GRAVITY'
        )
      end
      let(:data_file) { "#{docs_path}/_constants/space/gravity.yml" }

      it 'should return a passing result' do
        expect(generator.call)
          .to be_a_passing_result
          .with_value([data_file])
      end

      it 'should generate the data file', :aggregate_failures do
        expect { generator.call }.to(
          change { file_system.file?(data_file) }.to(be true)
        )

        expect(file_system.read(data_file)).to eq(data_contents)
      end

      include_deferred 'should write the output'
    end

    describe 'with a method object' do
      let(:object) do
        mock_data(
          SleepingKingStudios::Docs::Data::MethodObject,
          data_path: 'space/rocket/i-launch',
          name:      'Space::Rocket#launch'
        )
      end
      let(:data_file) { "#{docs_path}/_methods/space/rocket/i-launch.yml" }

      it 'should return a passing result' do
        expect(generator.call)
          .to be_a_passing_result
          .with_value([data_file])
      end

      it 'should generate the data file', :aggregate_failures do
        expect { generator.call }.to(
          change { file_system.file?(data_file) }.to(be true)
        )

        expect(file_system.read(data_file)).to eq(data_contents)
      end

      include_deferred 'should write the output'
    end
  end
end
