# frozen_string_literal: true

require 'sleeping_king_studios/docs/errors/outdated_documentation'

RSpec.describe SleepingKingStudios::Docs::Errors::OutdatedDocumentation do
  subject(:error) { described_class.new(**options) }

  let(:docs_path) { 'path/to/docs' }
  let(:options)   { { docs_path: } }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'sleeping_king_studios.docs.errors.outdated_documentation'
  end

  describe '.new' do
    let(:expected_keywords) do
      %i[
        changed_files
        docs_path
        extra_files
        missing_files
        version
      ]
    end

    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(*expected_keywords)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'docs_path'     => docs_path,
          'changed_files' => error.changed_files,
          'extra_files'   => error.extra_files,
          'missing_files' => error.missing_files,
          'version'       => error.version
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { expected }

    context 'when initialized with changed_files: value' do
      let(:changed_files) { %w[path/to/docs/changed/file.yml] }
      let(:options)       { super().merge(changed_files:) }

      it { expect(error.as_json).to eq(expected) }
    end

    context 'when initialized with extra_files: value' do
      let(:extra_files) { %w[path/to/docs/extra/file.yml] }
      let(:options)     { super().merge(extra_files:) }

      it { expect(error.as_json).to eq(expected) }
    end

    context 'when initialized with missing_files: value' do
      let(:missing_files) { %w[path/to/docs/missing/file.yml] }
      let(:options)       { super().merge(missing_files:) }

      it { expect(error.as_json).to eq(expected) }
    end

    context 'when initialized with version: value' do
      let(:version) { '1.12.3' }
      let(:options) { super().merge(version:) }

      it { expect(error.as_json).to eq(expected) }
    end
  end

  describe '#changed_files' do
    include_examples 'should define reader', :changed_files, []

    context 'when initialized with changed_files: value' do
      let(:changed_files) { %w[path/to/docs/changed/file.yml] }
      let(:options)       { super().merge(changed_files:) }

      it { expect(error.changed_files).to eq(changed_files) }
    end
  end

  describe '#docs_path' do
    include_examples 'should define reader', :docs_path, -> { docs_path }
  end

  describe '#extra_files' do
    include_examples 'should define reader', :extra_files, []

    context 'when initialized with extra_files: value' do
      let(:extra_files) { %w[path/to/docs/extra/file.yml] }
      let(:options)     { super().merge(extra_files:) }

      it { expect(error.extra_files).to eq(extra_files) }
    end
  end

  describe '#message' do
    let(:expected) do
      'outdated documentation found for current version'
    end

    it { expect(error.message).to eq(expected) }
  end

  describe '#missing_files' do
    include_examples 'should define reader', :missing_files, []

    context 'when initialized with missing_files: value' do
      let(:missing_files) { %w[path/to/docs/missing/file.yml] }
      let(:options)       { super().merge(missing_files:) }

      it { expect(error.missing_files).to eq(missing_files) }
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end

  describe '#version' do
    include_examples 'should define reader', :version, nil

    context 'when initialized with version: value' do
      let(:version) { '1.12.3' }
      let(:options) { super().merge(version:) }

      it { expect(error.version).to eq(version) }
    end
  end
end
