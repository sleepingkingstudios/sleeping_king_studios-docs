# frozen_string_literal: true

require 'sleeping_king_studios/docs'

RSpec.describe SleepingKingStudios::Docs do
  describe '::VERSION' do
    it 'should define the constant' do
      expect(described_class)
        .to have_constant(:VERSION)
        .with_value(SleepingKingStudios::Docs::Version.to_gem_version)
    end
  end

  describe '::gem_path' do
    let(:expected) do
      __dir__.sub(
        /#{File.join('', 'spec', 'sleeping_king_studios', '')}?\z/,
        ''
      )
    end

    include_examples 'should define class reader',
      :gem_path,
      -> { be == expected }
  end

  describe '::version' do
    it 'should define the reader' do
      expect(described_class)
        .to have_reader(:version)
        .with_value(SleepingKingStudios::Docs::Version.to_gem_version)
    end
  end
end
