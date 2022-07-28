# frozen_string_literal: true

require 'sleeping_king_studios/yard/errors/file_already_exists'

RSpec.describe SleepingKingStudios::Yard::Errors::FileAlreadyExists do
  subject(:error) { described_class.new(path: path) }

  let(:path) { 'path/to/file.txt' }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'sleeping_king_studios.yard.errors.file_already_exists'
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
    let(:expected) { "file already exists at #{path.inspect}" }

    include_examples 'should define reader', :message, -> { be == expected }
  end

  describe '#path' do
    include_examples 'should define reader', :path, -> { path }
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
