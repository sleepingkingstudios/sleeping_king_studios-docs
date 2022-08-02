# frozen_string_literal: true

require 'sleeping_king_studios/yard/errors/file_error'

RSpec.describe SleepingKingStudios::Yard::Errors::FileError do
  subject(:error) { described_class.new(message: message, path: path) }

  let(:message) { 'something went wrong' }
  let(:path)    { 'path/to/files' }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'sleeping_king_studios.yard.errors.file_error'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:message, :path)
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
    include_examples 'should define reader', :message, -> { message }
  end

  describe '#path' do
    include_examples 'should define reader', :path, -> { path }
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
