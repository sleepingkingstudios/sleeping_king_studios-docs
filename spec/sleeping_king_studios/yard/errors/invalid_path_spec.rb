# frozen_string_literal: true

require 'sleeping_king_studios/yard/errors/invalid_path'

RSpec.describe SleepingKingStudios::Yard::Errors::InvalidPath do
  subject(:error) do
    described_class.new(path: path, **constructor_options)
  end

  let(:path)                { 'path/to/files' }
  let(:constructor_options) { {} }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'sleeping_king_studios.yard.errors.invalid_path'
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
    let(:expected) { "invalid file or directory path #{path.inspect}" }

    include_examples 'should define reader', :message, -> { be == expected }

    context 'when initialized with a message' do
      let(:message)             { 'something went wrong' }
      let(:constructor_options) { super().merge(message: message) }
      let(:expected)            { "#{super()} - #{message}" }

      it { expect(error.message).to be == expected }
    end
  end

  describe '#path' do
    include_examples 'should define reader', :path, -> { path }
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
