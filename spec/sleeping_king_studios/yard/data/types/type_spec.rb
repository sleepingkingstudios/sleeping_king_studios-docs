# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/types/type'

require 'support/contracts/data/type_contract'

RSpec.describe SleepingKingStudios::Yard::Data::Types::Type do
  include Spec::Support::Contracts::Data

  subject(:type) { described_class.new(name: name) }

  let(:name) { 'Rocket' }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:name)
    end
  end

  include_contract 'should be a type object'

  describe '#inspect' do
    let(:expected) { "#<Type @name=#{name.inspect}>" }

    it { expect(type.inspect).to be == expected }
  end
end
