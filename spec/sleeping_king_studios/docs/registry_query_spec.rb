# frozen_string_literal: true

require 'sleeping_king_studios/docs/registry_query'

RSpec.describe SleepingKingStudios::Docs::RegistryQuery do
  subject(:query) { described_class.new(registry:) }

  let(:registry) { YARD::Registry }

  before(:context) { YARD::Registry.clear } # rubocop:disable RSpec/BeforeAfterAll

  after(:example) { YARD::Registry.clear }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:registry)
    end
  end

  describe '#class_method_exists?' do
    let(:method_name) { 'Namespace.class_method' }

    it { expect(query).to respond_to(:class_method_exists?).with(1).argument }

    it { expect(query.class_method_exists?(method_name)).to be false }

    context 'when the method is defined' do
      let(:ruby) do
        <<~RUBY
          module Namespace
            def self.class_method; end
          end
        RUBY
      end

      before(:example) { YARD.parse_string(ruby) }

      it { expect(query.class_method_exists?(method_name)).to be true }
    end

    describe 'with a legacy-style class method name' do
      let(:method_name) { 'Namespace::legacy_class_method' }

      it { expect(query.class_method_exists?(method_name)).to be false }

      context 'when the method is defined' do
        let(:ruby) do
          <<~RUBY
            module Namespace
              def self.legacy_class_method; end
            end
          RUBY
        end

        before(:example) { YARD.parse_string(ruby) }

        it { expect(query.class_method_exists?(method_name)).to be true }
      end
    end

    describe 'with a top-level class method name' do
      let(:method_name) { '.top_level_class_method' }

      it { expect(query.class_method_exists?(method_name)).to be false }

      context 'when the method is defined' do
        let(:ruby) do
          <<~RUBY
            def self.top_level_class_method; end
          RUBY
        end

        before(:example) { YARD.parse_string(ruby) }

        it { expect(query.class_method_exists?(method_name)).to be true }
      end
    end
  end

  describe '#constant_exists?' do
    let(:constant_name) { 'Namespace::CONSTANT' }

    it { expect(query).to respond_to(:constant_exists?).with(1).argument }

    it { expect(query.constant_exists?(constant_name)).to be false }

    context 'when the constant is defined' do
      let(:ruby) do
        <<~RUBY
          module Namespace
            CONSTANT = 'value'
          end
        RUBY
      end

      before(:example) { YARD.parse_string(ruby) }

      it { expect(query.constant_exists?(constant_name)).to be true }
    end

    describe 'with a top-level constant name' do
      let(:constant_name) { 'CONSTANT' }

      it { expect(query.constant_exists?(constant_name)).to be false }

      context 'when the constant is defined' do
        let(:ruby) do
          <<~RUBY
            CONSTANT = 'value'
          RUBY
        end

        before(:example) { YARD.parse_string(ruby) }

        it { expect(query.constant_exists?(constant_name)).to be true }
      end
    end
  end

  describe '#definition_exists?' do
    let(:module_name) { 'Namespace::Definition' }

    it { expect(query).to respond_to(:definition_exists?).with(1).argument }

    it { expect(query.definition_exists?(module_name)).to be false }

    context 'when the class is defined' do
      let(:ruby) do
        <<~RUBY
          module Namespace
            class Definition; end
          end
        RUBY
      end

      before(:example) { YARD.parse_string(ruby) }

      it { expect(query.definition_exists?(module_name)).to be true }
    end

    context 'when the module is defined' do
      let(:ruby) do
        <<~RUBY
          module Namespace
            module Definition; end
          end
        RUBY
      end

      before(:example) { YARD.parse_string(ruby) }

      it { expect(query.definition_exists?(module_name)).to be true }
    end

    describe 'with a top-level class definition name' do
      let(:module_name) { 'Definition' }

      it { expect(query.definition_exists?(module_name)).to be false }

      context 'when the class is defined' do
        let(:ruby) do
          <<~RUBY
            class Definition; end
          RUBY
        end

        before(:example) { YARD.parse_string(ruby) }

        it { expect(query.definition_exists?(module_name)).to be true }
      end

      context 'when the module is defined' do
        let(:ruby) do
          <<~RUBY
            module Definition; end
          RUBY
        end

        before(:example) { YARD.parse_string(ruby) }

        it { expect(query.definition_exists?(module_name)).to be true }
      end
    end
  end

  describe '#instance_method_exists?' do
    let(:method_name) { 'Namespace#instance_method' }

    it 'should define the method' do
      expect(query).to respond_to(:instance_method_exists?).with(1).argument
    end

    it { expect(query.instance_method_exists?(method_name)).to be false }

    context 'when the method is defined' do
      let(:ruby) do
        <<~RUBY
          module Namespace
            def instance_method; end
          end
        RUBY
      end

      before(:example) { YARD.parse_string(ruby) }

      it { expect(query.instance_method_exists?(method_name)).to be true }
    end

    describe 'with a top-level instance method name' do
      let(:method_name) { '#instance_method' }

      it { expect(query.instance_method_exists?(method_name)).to be false }

      context 'when the method is defined' do
        let(:ruby) do
          <<~RUBY
            def instance_method; end
          RUBY
        end

        before(:example) { YARD.parse_string(ruby) }

        it { expect(query.instance_method_exists?(method_name)).to be true }
      end
    end
  end

  describe '#registry' do
    include_examples 'should define private reader',
      :registry,
      -> { YARD::Registry }
  end
end
