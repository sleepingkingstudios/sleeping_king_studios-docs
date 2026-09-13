# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'support/deferred'

module Spec::Support::Deferred
  # Deferred examples for testing reference commands.
  module ReferenceExamples # rubocop:disable Metrics/ModuleLength
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should implement the path helpers' do
      describe '#class_data_directory' do
        let(:expected) { 'docs/_classes' }

        before(:example) { command.call(**options) }

        include_examples 'should define reader', :class_data_directory

        it { expect(subject.class_data_directory).to be == expected }

        context 'when called with docs_path: value' do
          let(:docs_path) { 'path/to/docs' }
          let(:options)   { super().merge(docs_path:) }
          let(:expected)  { 'path/to/docs/_classes' }

          it { expect(subject.class_data_directory).to be == expected }
        end

        context 'when called with version: value' do
          let(:version)  { '0.1.2' }
          let(:options)  { super().merge(version:) }
          let(:expected) { 'docs/_classes/version--0.1.2' }

          it { expect(subject.class_data_directory).to be == expected }
        end
      end

      describe '#constant_data_directory' do
        let(:expected) { 'docs/_constants' }

        before(:example) { command.call(**options) }

        include_examples 'should define reader', :constant_data_directory

        it { expect(subject.constant_data_directory).to be == expected }

        context 'when called with docs_path: value' do
          let(:docs_path) { 'path/to/docs' }
          let(:options)   { super().merge(docs_path:) }
          let(:expected)  { 'path/to/docs/_constants' }

          it { expect(subject.constant_data_directory).to be == expected }
        end

        context 'when called with version: value' do
          let(:version)  { '0.1.2' }
          let(:options)  { super().merge(version:) }
          let(:expected) { 'docs/_constants/version--0.1.2' }

          it { expect(subject.constant_data_directory).to be == expected }
        end
      end

      describe '#method_data_directory' do
        let(:expected) { 'docs/_methods' }

        before(:example) { command.call(**options) }

        include_examples 'should define reader', :method_data_directory

        it { expect(subject.method_data_directory).to be == expected }

        context 'when called with docs_path: value' do
          let(:docs_path) { 'path/to/docs' }
          let(:options)   { super().merge(docs_path:) }
          let(:expected)  { 'path/to/docs/_methods' }

          it { expect(subject.method_data_directory).to be == expected }
        end

        context 'when called with version: value' do
          let(:version)  { '0.1.2' }
          let(:options)  { super().merge(version:) }
          let(:expected) { 'docs/_methods/version--0.1.2' }

          it { expect(subject.method_data_directory).to be == expected }
        end
      end

      describe '#module_data_directory' do
        let(:expected) { 'docs/_modules' }

        before(:example) { command.call(**options) }

        include_examples 'should define reader', :method_data_directory

        it { expect(subject.module_data_directory).to be == expected }

        context 'when called with docs_path: value' do
          let(:docs_path) { 'path/to/docs' }
          let(:options)   { super().merge(docs_path:) }
          let(:expected)  { 'path/to/docs/_modules' }

          it { expect(subject.module_data_directory).to be == expected }
        end

        context 'when called with version: value' do
          let(:version)  { '0.1.2' }
          let(:options)  { super().merge(version:) }
          let(:expected) { 'docs/_modules/version--0.1.2' }

          it { expect(subject.module_data_directory).to be == expected }
        end
      end

      describe '#namespace_data_directory' do
        let(:expected) { 'docs/_namespaces' }

        before(:example) { command.call(**options) }

        include_examples 'should define reader', :namespace_data_directory

        it { expect(subject.namespace_data_directory).to be == expected }

        context 'when called with docs_path: value' do
          let(:docs_path) { 'path/to/docs' }
          let(:options)   { super().merge(docs_path:) }
          let(:expected)  { 'path/to/docs/_namespaces' }

          it { expect(subject.namespace_data_directory).to be == expected }
        end

        context 'when called with version: value' do
          let(:version)  { '0.1.2' }
          let(:options)  { super().merge(version:) }
          let(:expected) { 'docs/_namespaces/version--0.1.2' }

          it { expect(subject.namespace_data_directory).to be == expected }
        end
      end

      describe '#reference_directory' do
        let(:expected) { 'docs/reference' }

        before(:example) { command.call(**options) }

        include_examples 'should define reader', :reference_directory

        it { expect(subject.reference_directory).to be == expected }

        context 'when called with docs_path: value' do
          let(:docs_path) { 'path/to/docs' }
          let(:options)   { super().merge(docs_path:) }
          let(:expected)  { 'path/to/docs/reference' }

          it { expect(subject.reference_directory).to be == expected }
        end

        context 'when called with version: value' do
          let(:version)  { '0.1.2' }
          let(:options)  { super().merge(version:) }
          let(:expected) { 'docs/versions/0.1.2/reference' }

          it { expect(subject.reference_directory).to be == expected }
        end
      end
    end
  end
end
