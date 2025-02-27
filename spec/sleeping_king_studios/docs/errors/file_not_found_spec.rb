# frozen_string_literal: true

require 'sleeping_king_studios/docs/errors/file_not_found'

RSpec.describe SleepingKingStudios::Docs::Errors::FileNotFound do
  subject(:error) { described_class.new(path:) }

  let(:path) { 'path/to/file.txt' }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'sleeping_king_studios.docs.errors.file_not_found'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:path)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => { 'path' => path },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }
  end

  describe '#message' do
    let(:expected) { "file or directory not found at #{path.inspect}" }

    include_examples 'should define reader', :message, -> { be == expected }
  end

  describe '#path' do
    include_examples 'should define reader', :path, -> { path }
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
