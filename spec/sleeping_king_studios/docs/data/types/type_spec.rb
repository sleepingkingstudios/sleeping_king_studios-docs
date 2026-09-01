# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/types/type'

require 'support/deferred/data_examples'

RSpec.describe SleepingKingStudios::Docs::Data::Types::Type do
  include Spec::Support::Deferred::DataExamples

  subject(:type) { described_class.new(name:) }

  let(:name) { 'Rocket' }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:name)
    end
  end

  include_deferred 'should be a type object'

  describe '#inspect' do
    let(:expected) { "#<Type @name=#{name.inspect}>" }

    it { expect(type.inspect).to be == expected }
  end
end
