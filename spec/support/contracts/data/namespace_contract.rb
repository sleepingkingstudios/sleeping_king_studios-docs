# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'support/contracts/data'

module Spec::Support::Contracts::Data
  class ShouldImplementTheNamespaceMethods
    extend RSpec::SleepingKingStudios::Contract

    # @!method apply(example_group)
    #   Adds the contract to the example group.
    #
    #   @param expected_json [Hash{String, Object}] the expected base response
    #     for #as_json.
    #   @param include_mixins [Boolean] if true, includes expected class and
    #     instance methods from extend-ed and include-ed modules.
    #   @param inherit_mixins [Boolean] if true, includes expected class and
    #     instance methods from inherited classes.
    contract do |expected_json:, include_mixins: true, inherit_mixins: false|
      let(:data_object) { subject }

      describe '#as_json' do
        let(:expected) { instance_exec(&expected_json) }

        it { expect(data_object).to respond_to(:as_json).with(0).arguments }

        it { expect(data_object.as_json).to be == expected }

        wrap_context 'using fixture', 'with class attributes' do
          let(:expected) do
            super().merge('class_attributes' => data_object.class_attributes)
          end

          it { expect(data_object.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with class methods' do
          let(:expected) do
            super().merge('class_methods' => data_object.class_methods)
          end

          it { expect(data_object.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with constants' do
          let(:expected) do
            super().merge('constants' => data_object.constants)
          end

          it { expect(data_object.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with defined classes' do
          let(:expected) do
            super().merge('defined_classes' => data_object.defined_classes)
          end

          it { expect(data_object.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with defined modules' do
          let(:expected) do
            super().merge('defined_modules' => data_object.defined_modules)
          end

          it { expect(data_object.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with instance attributes' do
          let(:expected) do
            super().merge(
              'instance_attributes' => data_object.instance_attributes
            )
          end

          it { expect(data_object.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with instance methods' do
          let(:expected) do
            super().merge('instance_methods' => data_object.instance_methods)
          end

          it { expect(data_object.as_json).to be == expected }
        end
      end

      describe '#class_attributes' do
        include_examples 'should define reader', :class_attributes, []

        wrap_context 'using fixture', 'with class attributes' do
          let(:expected) do
            [
              {
                'name'  => 'gravity',
                'read'  => true,
                'write' => false
              },
              {
                'name'  => 'sandbox_mode',
                'read'  => true,
                'write' => true
              },
              {
                'name'  => 'secret_key',
                'read'  => false,
                'write' => true
              }
            ]
          end

          it { expect(data_object.class_attributes).to be == expected }
        end

        wrap_context 'using fixture', 'with everything' do
          let(:expected) do
            [
              {
                'name'  => 'gravity',
                'read'  => true,
                'write' => false
              },
              {
                'name'  => 'sandbox_mode',
                'read'  => true,
                'write' => true
              },
              {
                'name'  => 'secret_key',
                'read'  => false,
                'write' => true
              }
            ]
          end

          it { expect(data_object.class_attributes).to be == expected }
        end
      end

      describe '#class_methods' do
        include_examples 'should define reader', :class_methods, []

        wrap_context 'using fixture', 'with class methods' do
          let(:expected) { %w[calculate_isp plot_trajectory] }

          it { expect(data_object.class_methods).to be == expected }
        end

        if include_mixins
          wrap_context 'using fixture', 'with extended modules' do
            let(:expected) { %w[dew_point temperature] }

            it { expect(data_object.class_methods).to be == expected }
          end
        end

        if inherit_mixins
          wrap_context 'using fixture', 'with inherited classes' do
            let(:expected) { %w[design] }

            it { expect(data_object.class_methods).to be == expected }
          end
        end

        wrap_context 'using fixture', 'with everything' do
          let(:expected) do
            ary = %w[calculate_isp plot_trajectory]

            ary += %w[dew_point temperature] if include_mixins
            ary += %w[design]                if inherit_mixins

            ary.sort
          end

          it { expect(data_object.class_methods).to be == expected }
        end
      end

      describe '#constants' do
        include_examples 'should define reader', :constants, []

        wrap_context 'using fixture', 'with constants' do
          let(:expected) { %w[ELDRITCH SQUAMOUS] }

          it { expect(data_object.constants).to be == expected }
        end

        wrap_context 'using fixture', 'with everything' do
          let(:expected) { %w[ELDRITCH SQUAMOUS] }

          it { expect(data_object.constants).to be == expected }
        end
      end

      describe '#defined_classes' do
        include_examples 'should define reader', :defined_classes, []

        wrap_context 'using fixture', 'with defined classes' do
          let(:expected) do
            [
              {
                'name' => 'FuelTank',
                'slug' => 'fuel-tank'
              },
              {
                'name' => 'Part',
                'slug' => 'part'
              },
              {
                'name' => 'Rocket',
                'slug' => 'rocket'
              }
            ]
          end

          it { expect(data_object.defined_classes).to be == expected }
        end

        wrap_context 'using fixture', 'with everything' do
          let(:expected) do
            [
              {
                'name' => 'FuelTank',
                'slug' => 'fuel-tank'
              },
              {
                'name' => 'Part',
                'slug' => 'part'
              },
              {
                'name' => 'Rocket',
                'slug' => 'rocket'
              }
            ]
          end

          it { expect(data_object.defined_classes).to be == expected }
        end
      end

      describe '#defined_modules' do
        include_examples 'should define reader', :defined_modules, []

        wrap_context 'using fixture', 'with defined modules' do
          let(:expected) do
            [
              {
                'name' => 'Alchemy',
                'slug' => 'alchemy'
              },
              {
                'name' => 'Clockwork',
                'slug' => 'clockwork'
              },
              {
                'name' => 'ShadowMagic',
                'slug' => 'shadow-magic'
              }
            ]
          end

          it { expect(data_object.defined_modules).to be == expected }
        end

        wrap_context 'using fixture', 'with everything' do
          let(:expected) do
            [
              {
                'name' => 'Alchemy',
                'slug' => 'alchemy'
              },
              {
                'name' => 'Clockwork',
                'slug' => 'clockwork'
              },
              {
                'name' => 'ShadowMagic',
                'slug' => 'shadow-magic'
              }
            ]
          end

          it { expect(data_object.defined_modules).to be == expected }
        end
      end

      describe '#instance_attributes' do
        include_examples 'should define reader', :instance_attributes, []

        wrap_context 'using fixture', 'with instance attributes' do
          let(:expected) do
            [
              {
                'name'  => 'base_mana',
                'read'  => true,
                'write' => false
              },
              {
                'name'  => 'magic_enabled',
                'read'  => true,
                'write' => true
              },
              {
                'name'  => 'secret_formula',
                'read'  => false,
                'write' => true
              }
            ]
          end

          it { expect(data_object.instance_attributes).to be == expected }
        end

        wrap_context 'using fixture', 'with everything' do
          let(:expected) do
            [
              {
                'name'  => 'base_mana',
                'read'  => true,
                'write' => false
              },
              {
                'name'  => 'magic_enabled',
                'read'  => true,
                'write' => true
              },
              {
                'name'  => 'secret_formula',
                'read'  => false,
                'write' => true
              }
            ]
          end

          it { expect(data_object.instance_attributes).to be == expected }
        end
      end

      describe '#instance_methods' do
        include_examples 'should define reader', :instance_methods, []

        if include_mixins
          wrap_context 'using fixture', 'with included modules' do
            let(:expected) { %w[cardinality] }

            it { expect(data_object.instance_methods).to be == expected }
          end
        end

        if inherit_mixins
          wrap_context 'using fixture', 'with constructor' do
            let(:expected) { %w[initialize] }

            it { expect(data_object.instance_methods).to be == expected }
          end

          wrap_context 'using fixture', 'with inherited constructor' do
            let(:expected) { %w[initialize] }

            it { expect(data_object.instance_methods).to be == expected }
          end

          wrap_context 'using fixture', 'with inherited classes' do
            let(:expected) { %w[project_orion] }

            it { expect(data_object.instance_methods).to be == expected }
          end
        end

        wrap_context 'using fixture', 'with instance methods' do
          let(:expected) { %w[convert_mana summon_dark_lord] }

          it { expect(data_object.instance_methods).to be == expected }
        end

        wrap_context 'using fixture', 'with everything' do
          let(:expected) do
            ary = %w[convert_mana summon_dark_lord]

            ary += %w[cardinality]              if include_mixins
            ary += %w[initialize project_orion] if inherit_mixins

            ary.sort
          end

          it { expect(data_object.instance_methods).to be == expected }
        end
      end
    end
  end
end
