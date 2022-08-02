# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'support/contracts/data'

module Spec::Support::Contracts::Data
  class ShouldBeADescribableObject
    extend RSpec::SleepingKingStudios::Contract

    # @!method apply(example_group)
    #   Adds the contract to the example group.
    #
    #   @param basic_name [String] a basic name for the data object.
    #   @param complex_name [String] a multipart name for the data object.
    #   @param description [String] the short description for the data object.
    #   @param expected_json [Hash{String => Object}] the expected base response
    #     for #as_json.
    #   @param scoped_name [String] a name for the data object, including a
    #     class or module scope.
    #   @param separator [String] the string used to separate the named object
    #     from the scope.
    contract do | # rubocop:disable Metrics/ParameterLists
      basic_name:,
      complex_name:,
      description:,
      scoped_name:,
      expected_json:,
      data_path: true,
      separator: '::'
    |
      let(:data_object) { subject }

      describe '#as_json' do
        let(:expected) { instance_exec(&expected_json) }

        wrap_context 'using fixture', 'undocumented' do
          it { expect(data_object.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with full description' do
          let(:expected) do
            super().merge('description' => data_object.description)
          end

          it { expect(data_object.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with metadata' do
          let(:expected) do
            super().merge('metadata' => data_object.metadata)
          end

          it { expect(data_object.as_json).to be == expected }
        end
      end

      if data_path
        describe '#data_path' do
          def tools
            SleepingKingStudios::Tools::Toolbelt.instance
          end

          include_examples 'should define reader',
            :data_path,
            -> { tools.str.underscore(basic_name) }

          wrap_context 'using fixture', 'with complex name' do
            let(:fixture_name) { complex_name }
            let(:expected) do
              tools.str.underscore(complex_name).tr('_', '-')
            end

            it { expect(data_object.data_path).to be == expected }
          end

          wrap_context 'using fixture', 'with scoped name' do
            let(:fixture_name) { scoped_name }
            let(:expected) do
              scoped_name
                .split(separator)
                .map { |str| tools.str.underscore(str).tr('_', '-') }
                .join('/')
            end

            it { expect(data_object.data_path).to be == expected }
          end
        end
      end

      describe '#description' do
        include_examples 'should define reader', :description, nil

        wrap_context 'using fixture', 'undocumented' do
          it { expect(data_object.description).to be nil }
        end

        wrap_context 'using fixture', 'with full description' do
          let(:expected) do
            <<~TEXT.strip
              This object has a full description. It is comprised of a short description,
              followed by a multiline explanation, a list, and an essay cliche.

              - This is a description item.
              - This is another description item.

              In conclusion, space is a land of contrasts.
            TEXT
          end

          it { expect(data_object.description.class).to be String }

          it { expect(data_object.description).to be == expected }
        end

        wrap_context 'using fixture', 'with everything' do
          let(:expected) do
            <<~TEXT.strip
              This object has a full description. It is comprised of a short description,
              followed by a multiline explanation, a list, and an essay cliche.

              - This is a description item.
              - This is another description item.

              In conclusion, space is a land of contrasts.
            TEXT
          end

          it { expect(data_object.description).to be == expected }
        end
      end

      describe '#metadata' do
        include_examples 'should define reader', :metadata, {}

        def format_see_tag(tag)
          SleepingKingStudios::Yard::Data::SeeTag
            .new(native: tag)
            .as_json
        end

        wrap_context 'using fixture', 'with metadata' do
          let(:see_tags) do
            native
              .tags
              .select { |tag| tag.tag_name == 'see' }
              .map { |tag| format_see_tag(tag) }
          end
          let(:expected) do
            {
              'notes'    => ['This is a note.'],
              'examples' => [
                {
                  'name' => 'Named Example',
                  'text' => '# This is a named example.'
                }
              ],
              'see'      => see_tags,
              'todos'    => ['Remove the plutonium.']
            }
          end

          it { expect(data_object.metadata).to be == expected }
        end

        wrap_context 'using fixture', 'with everything' do
          let(:see_tags) do
            native
              .tags
              .select { |tag| tag.tag_name == 'see' }
              .map { |tag| format_see_tag(tag) }
          end
          let(:expected) do
            {
              'notes'    => ['This is a note.'],
              'examples' => [
                {
                  'name' => 'Named Example',
                  'text' => '# This is a named example.'
                }
              ],
              'see'      => see_tags,
              'todos'    => ['Remove the plutonium.']
            }
          end

          it { expect(data_object.metadata).to be == expected }
        end
      end

      describe '#name' do
        include_examples 'should define reader', :name, basic_name

        wrap_context 'using fixture', 'with complex name' do
          let(:fixture_name) { complex_name }

          it { expect(data_object.name).to be == complex_name }
        end

        wrap_context 'using fixture', 'with scoped name' do
          let(:fixture_name) { scoped_name }

          it { expect(data_object.name).to be == scoped_name }
        end
      end

      describe '#short_description' do
        let(:expected) { description }

        include_examples 'should define reader',
          :short_description,
          -> { expected }

        it { expect(data_object.short_description.class).to be String }

        wrap_context 'using fixture', 'undocumented' do
          it { expect(data_object.short_description).to be == '' }
        end

        wrap_context 'using fixture', 'with full description' do
          it { expect(data_object.short_description).to be == expected }
        end

        wrap_context 'using fixture', 'with everything' do
          it { expect(data_object.short_description).to be == expected }
        end
      end

      describe '#slug' do
        def tools
          SleepingKingStudios::Tools::Toolbelt.instance
        end

        include_examples 'should define reader',
          :slug,
          -> { tools.str.underscore(basic_name) }

        wrap_context 'using fixture', 'with complex name' do
          let(:fixture_name) { complex_name }
          let(:expected) do
            tools.str.underscore(complex_name).tr('_', '-')
          end

          it { expect(data_object.slug).to be == expected }
        end

        wrap_context 'using fixture', 'with scoped name' do
          let(:fixture_name) { scoped_name }
          let(:expected) do
            scoped_name
              .split(separator)
              .last
              .then { |str| tools.str.underscore(str) }
              .tr('_', '-')
          end

          it { expect(data_object.slug).to be == expected }
        end
      end
    end
  end
end
