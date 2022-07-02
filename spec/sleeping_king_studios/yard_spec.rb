# frozen_string_literal: true

require 'sleeping_king_studios/yard'

RSpec.describe SleepingKingStudios::Yard do
  describe '::VERSION' do
    it 'should define the constant' do
      expect(described_class)
        .to have_constant(:VERSION)
        .with_value(SleepingKingStudios::Yard::Version.to_gem_version)
    end
  end

  describe '::version' do
    it 'should define the reader' do
      expect(described_class)
        .to have_reader(:version)
        .with_value(SleepingKingStudios::Yard::Version.to_gem_version)
    end
  end
end
