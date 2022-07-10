# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/base'

require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::Base do
  include Spec::Support::Fixtures

  subject(:constant_object) do
    described_class.new(native: native, registry: registry)
  end

  include_context 'with fixture files', 'modules'

  let(:fixture)  { 'basic.rb' }
  let(:registry) { ::YARD::Registry }
  let(:native)   { registry.root }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:native, :registry)
    end
  end

  describe '#native' do
    include_examples 'should define private reader', :native, -> { native }
  end

  describe '#registry' do
    include_examples 'should define private reader',
      :registry,
      -> { ::YARD::Registry }
  end
end
