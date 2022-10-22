# frozen_string_literal: true

require 'stringio'

require 'rspec/sleeping_king_studios/contract'

require 'support/contracts/commands'

module Spec::Support::Contracts::Commands
  class ShouldBeAGeneratorCommand
    extend RSpec::SleepingKingStudios::Contract

    # @!method apply(example_group)
    #   Adds the contract to the example group.
    #
    #   @param constructor_keywords [Array<Symbol>] additional keywords expected
    #     by the constructor, if any.
    contract do |constructor_keywords: []|
      describe '.new' do
        it 'should define the constructor' do
          expect(described_class)
            .to be_constructible
            .with(0).arguments
            .and_keywords(:docs_path, *constructor_keywords)
            .and_any_keywords
        end
      end

      describe '#docs_path' do
        include_examples 'should define reader', :docs_path, -> { docs_path }
      end

      describe '#dry_run?' do
        include_examples 'should define predicate', :dry_run?, false

        context 'when initialized with dry_run: false' do
          let(:options) { super().merge(dry_run: false) }

          it { expect(subject.dry_run?).to be false }
        end

        context 'when initialized with dry_run: true' do
          let(:options) { super().merge(dry_run: true) }

          it { expect(subject.dry_run?).to be true }
        end
      end

      describe '#force?' do
        include_examples 'should define predicate', :force?, false

        context 'when initialized with force: false' do
          let(:options) { super().merge(force: false) }

          it { expect(subject.force?).to be false }
        end

        context 'when initialized with force: true' do
          let(:options) { super().merge(force: true) }

          it { expect(subject.force?).to be true }
        end
      end

      describe '#options' do
        let(:default_options) do
          return super() if defined?(super())

          {
            dry_run: false,
            force:   false,
            verbose: false
          }
        end

        include_examples 'should define reader',
          :options,
          -> { be == default_options }

        context 'when initialized with dry_run: false' do
          let(:options) { super().merge(dry_run: false) }

          it { expect(subject.options).to be == default_options }
        end

        context 'when initialized with dry_run: true' do
          let(:options)  { super().merge(dry_run: true) }
          let(:expected) { default_options.merge(dry_run: true) }

          it { expect(subject.options).to be == expected }
        end

        context 'when initialized with force: false' do
          let(:options) { super().merge(force: false) }

          it { expect(subject.options).to be == default_options }
        end

        context 'when initialized with force: true' do
          let(:options)  { super().merge(force: true) }
          let(:expected) { default_options.merge(force: true) }

          it { expect(subject.options).to be == expected }
        end

        context 'when initialized with template_path: value' do
          let(:template_path) { 'templates/reference' }
          let(:options)       { super().merge(template_path: template_path) }
          let(:expected) do
            default_options.merge(template_path: template_path)
          end

          it { expect(subject.options).to be == expected }
        end

        context 'when initialized with verbose: false' do
          let(:options) { super().merge(verbose: false) }

          it { expect(subject.options).to be == default_options }
        end

        context 'when initialized with verbose: true' do
          let(:options)  { super().merge(verbose: true) }
          let(:expected) { default_options.merge(verbose: true) }

          it { expect(subject.options).to be == expected }
        end

        context 'when initialized with version: value' do
          let(:options)  { super().merge(version: '1.10.101') }
          let(:expected) { default_options.merge(version: '1.10.101') }

          it { expect(subject.options).to be == expected }
        end

        context 'when initialized with other options' do
          let(:options)  { super().merge(key: 'value') }
          let(:expected) { default_options.merge(key: 'value') }

          it { expect(subject.options).to be == expected }
        end
      end

      describe '#template_path' do
        include_examples 'should define reader', :template_path, 'reference'

        context 'when initialized with template_path: value' do
          let(:template_path) { 'templates/reference' }
          let(:options)       { super().merge(template_path: template_path) }

          it { expect(subject.template_path).to be == template_path }
        end
      end

      describe '#verbose?' do
        include_examples 'should define predicate', :verbose, false

        context 'when initialized with verbose: false' do
          let(:options) { super().merge(verbose: false) }

          it { expect(subject.verbose?).to be false }
        end

        context 'when initialized with verbose: true' do
          let(:options) { super().merge(verbose: true) }

          it { expect(subject.verbose?).to be true }
        end
      end

      describe '#version' do
        include_examples 'should define reader', :version, nil

        context 'when initialized with version: value' do
          let(:options) { super().merge(version: '1.10.101') }

          it { expect(subject.version).to be == options[:version] }
        end
      end
    end
  end
end
