# frozen_string_literal: true

require 'sleeping_king_studios/docs/yard/build'

RSpec.describe SleepingKingStudios::Docs::Yard::Build do
  subject(:command) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    let(:expected_error) do
      message =
        "unable to parse native object #{native.inspect} - no matching data" \
        "type defined for #{native.class}"

      SleepingKingStudios::Docs::Errors::RegistryError.new(message:)
    end

    after(:example) { YARD::Registry.clear }

    describe 'with nil' do
      let(:native) { nil }

      it 'should return a failing result' do
        expect(command.call(native))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with an Object' do
      let(:native) { Object.new.freeze }

      it 'should return a failing result' do
        expect(command.call(native))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a YARD class' do
      let(:native) do
        YARD::CodeObjects::ClassObject.new(:root, 'Space::Rocket')
      end
      let(:expected_value) do
        be_a(SleepingKingStudios::Docs::Data::ClassObject).and(
          satisfy { |data| data.send(:native) == native }
        )
      end

      it 'should return a passing result' do
        expect(command.call(native))
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    describe 'with a YARD constant' do
      let(:native) do
        YARD::CodeObjects::ConstantObject.new(:root, 'Space::GRAVITY')
      end
      let(:expected_value) do
        be_a(SleepingKingStudios::Docs::Data::ConstantObject).and(
          satisfy { |data| data.send(:native) == native }
        )
      end

      it 'should return a passing result' do
        expect(command.call(native))
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    describe 'with a YARD method' do
      let(:native) do
        YARD::CodeObjects::MethodObject.new(:root, 'Space::Rocket#launch')
      end
      let(:expected_value) do
        be_a(SleepingKingStudios::Docs::Data::MethodObject).and(
          satisfy { |data| data.send(:native) == native }
        )
      end

      it 'should return a passing result' do
        expect(command.call(native))
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    describe 'with a YARD module' do
      let(:native) do
        YARD::CodeObjects::ModuleObject.new(:root, 'Space')
      end
      let(:expected_value) do
        be_a(SleepingKingStudios::Docs::Data::ModuleObject).and(
          satisfy { |data| data.send(:native) == native }
        )
      end

      it 'should return a passing result' do
        expect(command.call(native))
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end

    describe 'with a YARD namespace' do
      let(:native) do
        YARD::CodeObjects::NamespaceObject.new(:root, 'root')
      end

      it 'should return a failing result' do
        expect(command.call(native))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a YARD root namespace' do
      let(:native) do
        YARD::CodeObjects::RootObject.new(:root, 'root')
      end
      let(:expected_value) do
        be_a(SleepingKingStudios::Docs::Data::RootObject).and(
          satisfy { |data| data.send(:native) == native }
        )
      end

      it 'should return a passing result' do
        expect(command.call(native))
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end
  end
end
