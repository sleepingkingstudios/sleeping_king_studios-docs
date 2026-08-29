# frozen_string_literal: true

require 'cuprum/cli/rspec/deferred/options_examples'

require 'sleeping_king_studios/docs/jekyll/commands/clobber'

require 'support/deferred/reference_examples'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Commands::Clobber do
  include Cuprum::Cli::RSpec::Deferred::OptionsExamples
  include Spec::Support::Deferred::ReferenceExamples

  subject(:command) { described_class.new(file_system:, standard_io:) }

  deferred_context 'when initialized with reference files' do
    let(:docs_path) { options.fetch(:docs_path, 'docs') }
    let(:version)   { options[:version] }
    let(:files) do
      {
        '_classes'                  => {
          'space/rocket.yml' => 'name: Space::Rocket',
          'version--1.0'     => { 'space/rocket.yml' => 'name: Space::Rocket' },
          'version--2.0'     => { 'space/rocket.yml' => 'name: Space::Rocket' }
        },
        '_constants'                => {
          'space/gravity.yml' => 'name: Space::GRAVITY',
          'version--1.0'      => {
            'space/gravity.yml' => 'name: Space::GRAVITY'
          },
          'version--2.0'      => {
            'space/gravity.yml' => 'name: Space::GRAVITY'
          }
        },
        '_methods'                  => {
          'space/rocket/i-launch.yml' => 'name: Space::Rocket#launch',
          'version--1.0'              => {
            'space/rocket/i-launch.yml' => 'name: Space::Rocket#launch'
          },
          'version--2.0'              => {
            'space/rocket/i-launch.yml' => 'name: Space::Rocket#launch'
          }
        },
        '_modules'                  => {
          'space.yml'    => 'name: Space',
          'version--1.0' => { 'space.yml' => 'name: Space' },
          'version--2.0' => { 'space.yml' => 'name: Space' }
        },
        '_namespaces'               => {
          'root.yml'     => 'name: root',
          'version--1.0' => { 'root.yml' => 'name: root' },
          'version--2.0' => { 'root.yml' => 'name: root' }
        },
        'reference/index.md'        => 'Index file, do not delete.',
        'reference/space/rocket.md' => 'Nested reference file.',
        'reference/space.md'        => 'Top level reference file.',
        'versions'                  => {
          '1.0' => {
            'reference/index.md'        => 'Versioned index file.',
            'reference/space/rocket.md' => 'Versioned nested file.',
            'reference/space.md'        => 'Versioned top-level file.'
          },
          '2.0' => {
            'reference/index.md'        => 'Versioned index file.',
            'reference/space/rocket.md' => 'Versioned nested file.',
            'reference/space.md'        => 'Versioned top-level file.'
          }
        }
      }
        .transform_keys { |key| File.join(docs_path, key) }
    end
  end

  let(:files)       { {} }
  let(:file_system) { Cuprum::Cli::Dependencies::FileSystem::Mock.new(files:) }
  let(:standard_io) { Cuprum::Cli::Dependencies::StandardIo::Mock.new }
  let(:options)     { {} }

  include_deferred 'should define option',
    :docs_path,
    type:    :string,
    default: 'docs'

  include_deferred 'should define option',
    :version,
    type: :string

  include_deferred 'should implement the path helpers'

  describe '#call' do
    deferred_examples 'should output to STDOUT' do
      it 'should output to STDOUT' do
        call_command

        expect(standard_io.output_stream.string).to eq expected_output
      end

      it 'should not output to STDERR' do
        call_command

        expect(standard_io.error_stream.string).to eq ''
      end

      describe 'with quiet: true' do
        let(:options) { super().merge(quiet: true) }

        it 'should not output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq ''
        end

        it 'should not output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq ''
        end
      end

      describe 'with verbose: true' do
        let(:options) { super().merge(verbose: true) }

        it 'should output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq verbose_output
        end

        it 'should not output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq ''
        end
      end
    end

    deferred_examples 'should remove the files for the current version' do
      # rubocop:disable RSpec/ExampleLength
      it 'should remove the expected class files' do
        call_command

        expect(file_system.each_file("#{docs_path}/_classes/**"))
          .to contain_exactly(
            "#{docs_path}/_classes/version--1.0",
            "#{docs_path}/_classes/version--1.0/space",
            "#{docs_path}/_classes/version--1.0/space/rocket.yml",
            "#{docs_path}/_classes/version--2.0",
            "#{docs_path}/_classes/version--2.0/space",
            "#{docs_path}/_classes/version--2.0/space/rocket.yml"
          )
      end

      it 'should remove the expected constant files' do
        call_command

        expect(file_system.each_file("#{docs_path}/_constants/**"))
          .to contain_exactly(
            "#{docs_path}/_constants/version--1.0",
            "#{docs_path}/_constants/version--1.0/space",
            "#{docs_path}/_constants/version--1.0/space/gravity.yml",
            "#{docs_path}/_constants/version--2.0",
            "#{docs_path}/_constants/version--2.0/space",
            "#{docs_path}/_constants/version--2.0/space/gravity.yml"
          )
      end

      it 'should remove the expected method files' do
        call_command

        expect(file_system.each_file("#{docs_path}/_methods/**"))
          .to contain_exactly(
            "#{docs_path}/_methods/version--1.0",
            "#{docs_path}/_methods/version--1.0/space",
            "#{docs_path}/_methods/version--1.0/space/rocket",
            "#{docs_path}/_methods/version--1.0/space/rocket/i-launch.yml",
            "#{docs_path}/_methods/version--2.0",
            "#{docs_path}/_methods/version--2.0/space",
            "#{docs_path}/_methods/version--2.0/space/rocket",
            "#{docs_path}/_methods/version--2.0/space/rocket/i-launch.yml"
          )
      end

      it 'should remove the expected module files' do
        call_command

        expect(file_system.each_file("#{docs_path}/_modules/**"))
          .to contain_exactly(
            "#{docs_path}/_modules/version--1.0",
            "#{docs_path}/_modules/version--1.0/space.yml",
            "#{docs_path}/_modules/version--2.0",
            "#{docs_path}/_modules/version--2.0/space.yml"
          )
      end

      it 'should remove the expected namespace files' do
        call_command

        expect(file_system.each_file("#{docs_path}/_namespaces/**"))
          .to contain_exactly(
            "#{docs_path}/_namespaces/version--1.0",
            "#{docs_path}/_namespaces/version--1.0/root.yml",
            "#{docs_path}/_namespaces/version--2.0",
            "#{docs_path}/_namespaces/version--2.0/root.yml"
          )
      end

      it 'should remove the expected reference files', :aggregate_failures do
        call_command

        expect(file_system.each_file("#{docs_path}/reference/**"))
          .to contain_exactly("#{docs_path}/reference/index.md")
        expect(file_system.each_file("#{docs_path}/versions/**"))
          .to contain_exactly(
            "#{docs_path}/versions/1.0",
            "#{docs_path}/versions/1.0/reference",
            "#{docs_path}/versions/1.0/reference/index.md",
            "#{docs_path}/versions/1.0/reference/space",
            "#{docs_path}/versions/1.0/reference/space.md",
            "#{docs_path}/versions/1.0/reference/space/rocket.md",
            "#{docs_path}/versions/2.0",
            "#{docs_path}/versions/2.0/reference",
            "#{docs_path}/versions/2.0/reference/index.md",
            "#{docs_path}/versions/2.0/reference/space",
            "#{docs_path}/versions/2.0/reference/space.md",
            "#{docs_path}/versions/2.0/reference/space/rocket.md"
          )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    deferred_examples 'should remove the files for the specified version' do
      # rubocop:disable RSpec/ExampleLength
      it 'should remove the expected class files' do
        call_command

        expect(file_system.each_file("#{docs_path}/_classes/**"))
          .to contain_exactly(
            "#{docs_path}/_classes/space",
            "#{docs_path}/_classes/space/rocket.yml",
            "#{docs_path}/_classes/version--2.0",
            "#{docs_path}/_classes/version--2.0/space",
            "#{docs_path}/_classes/version--2.0/space/rocket.yml"
          )
      end

      it 'should remove the expected constant files' do
        call_command

        expect(file_system.each_file("#{docs_path}/_constants/**"))
          .to contain_exactly(
            "#{docs_path}/_constants/space",
            "#{docs_path}/_constants/space/gravity.yml",
            "#{docs_path}/_constants/version--2.0",
            "#{docs_path}/_constants/version--2.0/space",
            "#{docs_path}/_constants/version--2.0/space/gravity.yml"
          )
      end

      it 'should remove the expected method files' do
        call_command

        expect(file_system.each_file("#{docs_path}/_methods/**"))
          .to contain_exactly(
            "#{docs_path}/_methods/space",
            "#{docs_path}/_methods/space/rocket",
            "#{docs_path}/_methods/space/rocket/i-launch.yml",
            "#{docs_path}/_methods/version--2.0",
            "#{docs_path}/_methods/version--2.0/space",
            "#{docs_path}/_methods/version--2.0/space/rocket",
            "#{docs_path}/_methods/version--2.0/space/rocket/i-launch.yml"
          )
      end

      it 'should remove the expected module files' do
        call_command

        expect(file_system.each_file("#{docs_path}/_modules/**"))
          .to contain_exactly(
            "#{docs_path}/_modules/space.yml",
            "#{docs_path}/_modules/version--2.0",
            "#{docs_path}/_modules/version--2.0/space.yml"
          )
      end

      it 'should remove the expected namespace files' do
        call_command

        expect(file_system.each_file("#{docs_path}/_namespaces/**"))
          .to contain_exactly(
            "#{docs_path}/_namespaces/root.yml",
            "#{docs_path}/_namespaces/version--2.0",
            "#{docs_path}/_namespaces/version--2.0/root.yml"
          )
      end

      it 'should remove the expected reference files', :aggregate_failures do
        call_command

        expect(file_system.each_file("#{docs_path}/reference/**"))
          .to contain_exactly(
            "#{docs_path}/reference/index.md",
            "#{docs_path}/reference/space",
            "#{docs_path}/reference/space.md",
            "#{docs_path}/reference/space/rocket.md"
          )
        expect(file_system.each_file("#{docs_path}/versions/**"))
          .to contain_exactly(
            "#{docs_path}/versions/1.0",
            "#{docs_path}/versions/1.0/reference",
            "#{docs_path}/versions/1.0/reference/index.md",
            "#{docs_path}/versions/2.0",
            "#{docs_path}/versions/2.0/reference",
            "#{docs_path}/versions/2.0/reference/index.md",
            "#{docs_path}/versions/2.0/reference/space",
            "#{docs_path}/versions/2.0/reference/space.md",
            "#{docs_path}/versions/2.0/reference/space/rocket.md"
          )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    let(:docs_path) { 'docs' }
    let(:expected_output) do
      <<~OUTPUT
        Removing 0 files from #{docs_path}/reference...
        Removing 0 class objects from #{docs_path}/_classes...
        Removing 0 constant objects from #{docs_path}/_constants...
        Removing 0 method objects from #{docs_path}/_methods...
        Removing 0 module objects from #{docs_path}/_modules...
        Removing 0 namespace objects from #{docs_path}/_namespaces...
        Success!
      OUTPUT
    end
    let(:verbose_output) do
      <<~OUTPUT
        Removing 0 files from #{docs_path}/reference...

        Removing 0 class objects from #{docs_path}/_classes...

        Removing 0 constant objects from #{docs_path}/_constants...

        Removing 0 method objects from #{docs_path}/_methods...

        Removing 0 module objects from #{docs_path}/_modules...

        Removing 0 namespace objects from #{docs_path}/_namespaces...

        Success!
      OUTPUT
    end

    define_method :call_command do
      command.call(**options)
    end

    it 'should return a passing result' do
      expect(call_command)
        .to be_a_passing_result
        .with_value(nil)
    end

    include_deferred 'should output to STDOUT'

    describe 'with docs_path: value' do
      let(:docs_path) { 'path/to/docs' }
      let(:options)   { super().merge(docs_path:) }

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(nil)
      end

      include_deferred 'should output to STDOUT'
    end

    describe 'with version: value' do
      let(:version) { '1.0' }
      let(:options) { super().merge(version:) }
      let(:expected_output) do
        <<~OUTPUT
          Removing 0 files from #{docs_path}/versions/#{version}/reference...
          Removing 0 class objects from #{docs_path}/_classes/version--#{version}...
          Removing 0 constant objects from #{docs_path}/_constants/version--#{version}...
          Removing 0 method objects from #{docs_path}/_methods/version--#{version}...
          Removing 0 module objects from #{docs_path}/_modules/version--#{version}...
          Removing 0 namespace objects from #{docs_path}/_namespaces/version--#{version}...
          Success!
        OUTPUT
      end
      let(:verbose_output) do
        <<~OUTPUT
          Removing 0 files from #{docs_path}/versions/#{version}/reference...

          Removing 0 class objects from #{docs_path}/_classes/version--#{version}...

          Removing 0 constant objects from #{docs_path}/_constants/version--#{version}...

          Removing 0 method objects from #{docs_path}/_methods/version--#{version}...

          Removing 0 module objects from #{docs_path}/_modules/version--#{version}...

          Removing 0 namespace objects from #{docs_path}/_namespaces/version--#{version}...

          Success!
        OUTPUT
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(nil)
      end

      include_deferred 'should output to STDOUT'
    end

    wrap_deferred 'when initialized with reference files' do
      let(:expected_output) do
        <<~OUTPUT
          Removing 2 files from #{docs_path}/reference...
          Removing 1 class objects from #{docs_path}/_classes...
          Removing 1 constant objects from #{docs_path}/_constants...
          Removing 1 method objects from #{docs_path}/_methods...
          Removing 1 module objects from #{docs_path}/_modules...
          Removing 1 namespace objects from #{docs_path}/_namespaces...
          Success!
        OUTPUT
      end
      let(:verbose_output) do
        <<~OUTPUT
          Removing 2 files from #{docs_path}/reference...

            - Deleting file #{docs_path}/reference/space.md
            - Deleting file #{docs_path}/reference/space/rocket.md

          Removing 1 class objects from #{docs_path}/_classes...

            - Deleting file #{docs_path}/_classes/space/rocket.yml

          Removing 1 constant objects from #{docs_path}/_constants...

            - Deleting file #{docs_path}/_constants/space/gravity.yml

          Removing 1 method objects from #{docs_path}/_methods...

            - Deleting file #{docs_path}/_methods/space/rocket/i-launch.yml

          Removing 1 module objects from #{docs_path}/_modules...

            - Deleting file #{docs_path}/_modules/space.yml

          Removing 1 namespace objects from #{docs_path}/_namespaces...

            - Deleting file #{docs_path}/_namespaces/root.yml

          Success!
        OUTPUT
      end

      it 'should return a passing result' do
        expect(call_command)
          .to be_a_passing_result
          .with_value(nil)
      end

      include_deferred 'should output to STDOUT'

      include_deferred 'should remove the files for the current version'

      describe 'with docs_path: value' do
        let(:docs_path) { 'path/to/docs' }
        let(:options)   { super().merge(docs_path:) }

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(nil)
        end

        include_deferred 'should output to STDOUT'

        include_deferred 'should remove the files for the current version'
      end

      describe 'with version: value' do
        let(:version) { '1.0' }
        let(:options) { super().merge(version:) }
        let(:expected_output) do
          <<~OUTPUT
            Removing 2 files from #{docs_path}/versions/#{version}/reference...
            Removing 1 class objects from #{docs_path}/_classes/version--#{version}...
            Removing 1 constant objects from #{docs_path}/_constants/version--#{version}...
            Removing 1 method objects from #{docs_path}/_methods/version--#{version}...
            Removing 1 module objects from #{docs_path}/_modules/version--#{version}...
            Removing 1 namespace objects from #{docs_path}/_namespaces/version--#{version}...
            Success!
          OUTPUT
        end
        let(:verbose_output) do
          <<~OUTPUT
            Removing 2 files from #{docs_path}/versions/#{version}/reference...

              - Deleting file #{docs_path}/versions/#{version}/reference/space.md
              - Deleting file #{docs_path}/versions/#{version}/reference/space/rocket.md

            Removing 1 class objects from #{docs_path}/_classes/version--#{version}...

              - Deleting file #{docs_path}/_classes/version--#{version}/space/rocket.yml

            Removing 1 constant objects from #{docs_path}/_constants/version--#{version}...

              - Deleting file #{docs_path}/_constants/version--#{version}/space/gravity.yml

            Removing 1 method objects from #{docs_path}/_methods/version--#{version}...

              - Deleting file #{docs_path}/_methods/version--#{version}/space/rocket/i-launch.yml

            Removing 1 module objects from #{docs_path}/_modules/version--#{version}...

              - Deleting file #{docs_path}/_modules/version--#{version}/space.yml

            Removing 1 namespace objects from #{docs_path}/_namespaces/version--#{version}...

              - Deleting file #{docs_path}/_namespaces/version--#{version}/root.yml

            Success!
          OUTPUT
        end

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(nil)
        end

        include_deferred 'should output to STDOUT'

        include_deferred 'should remove the files for the specified version'
      end

      context 'when removing a file fails' do
        let(:expected_output) do
          <<~OUTPUT
            Removing 2 files from #{docs_path}/reference...
            Removing 1 class objects from #{docs_path}/_classes...
            Removing 1 constant objects from #{docs_path}/_constants...
            Removing 1 method objects from #{docs_path}/_methods...
            Removing 1 module objects from #{docs_path}/_modules...
            Removing 1 namespace objects from #{docs_path}/_namespaces...
          OUTPUT
        end
        let(:verbose_output) do
          <<~OUTPUT
            Removing 2 files from #{docs_path}/reference...

              - Deleting file #{docs_path}/reference/space.md
              - Unable to delete file #{docs_path}/reference/space/rocket.md

            Removing 1 class objects from #{docs_path}/_classes...

              - Deleting file #{docs_path}/_classes/space/rocket.yml

            Removing 1 constant objects from #{docs_path}/_constants...

              - Deleting file #{docs_path}/_constants/space/gravity.yml

            Removing 1 method objects from #{docs_path}/_methods...

              - Unable to delete file #{docs_path}/_methods/space/rocket/i-launch.yml

            Removing 1 module objects from #{docs_path}/_modules...

              - Deleting file #{docs_path}/_modules/space.yml

            Removing 1 namespace objects from #{docs_path}/_namespaces...

              - Deleting file #{docs_path}/_namespaces/root.yml

          OUTPUT
        end
        let(:expected_error) do
          message = 'unable to remove documentation files'
          errors  =
            [
              [
                "#{docs_path}/_methods/space/rocket/i-launch.yml",
                "can't delete reference file"
              ],
              [
                "#{docs_path}/reference/space",
                "unable to delete directory #{docs_path}/reference/space - " \
                'directory is not empty'
              ],
              [
                "#{docs_path}/_methods/space/rocket/i-launch.yml",
                "can't delete data file"
              ],
              [
                "#{docs_path}/_methods/space",
                "unable to delete directory #{docs_path}/_methods/space - " \
                'directory is not empty'
              ]
            ]
            .map do |(path, message)|
              SleepingKingStudios::Docs::Errors::FileError.new(message:, path:)
            end

          Cuprum::Errors::MultipleErrors.new(errors:, message:)
        end
        let(:expected_error_output) do
          <<~OUTPUT
            Failures:

              - Unable to remove #{docs_path}/reference/space/rocket.md - can't delete reference file
              - Unable to remove #{docs_path}/reference/space - unable to delete directory docs/reference/space - directory is not empty
              - Unable to remove #{docs_path}/_methods/space/rocket/i-launch.yml - can't delete data file
              - Unable to remove #{docs_path}/_methods/space - unable to delete directory docs/_methods/space - directory is not empty

          OUTPUT
        end

        before(:example) do
          allow(file_system).to receive(:delete_file).and_call_original

          allow(file_system)
            .to receive(:delete_file)
            .with("#{docs_path}/_methods/space/rocket/i-launch.yml")
            .and_raise(
              Cuprum::Cli::Dependencies::FileSystem::FileError,
              "can't delete data file"
            )

          allow(file_system)
            .to receive(:delete_file)
            .with("#{docs_path}/reference/space/rocket.md")
            .and_raise(
              Cuprum::Cli::Dependencies::FileSystem::FileError,
              "can't delete reference file"
            )
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_value(nil)
            .and_error(expected_error)
        end

        it 'should output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq expected_output
        end

        it 'should output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq expected_error_output
        end

        describe 'with quiet: true' do
          let(:options) { super().merge(quiet: true) }

          it 'should not output to STDOUT' do
            call_command

            expect(standard_io.output_stream.string).to eq ''
          end

          it 'should output to STDERR' do
            call_command

            expect(standard_io.error_stream.string).to eq expected_error_output
          end
        end

        describe 'with verbose: true' do
          let(:options) { super().merge(verbose: true) }

          it 'should output to STDOUT' do
            call_command

            expect(standard_io.output_stream.string).to eq verbose_output
          end

          it 'should output to STDERR' do
            call_command

            expect(standard_io.error_stream.string).to eq expected_error_output
          end
        end
      end
    end
  end
end
