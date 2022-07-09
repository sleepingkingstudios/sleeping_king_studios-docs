# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/module_object'

require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::ModuleObject do
  include Spec::Support::Fixtures

  subject(:module_object) do
    described_class.new(native: native, registry: registry)
  end

  include_context 'with fixture files', 'modules'

  let(:fixture)     { 'basic.rb' }
  let(:module_name) { 'Space' }
  let(:registry)    { ::YARD::Registry }
  let(:native)      { registry.find { |obj| obj.title == module_name } }

  def format_see_tag(tag)
    SleepingKingStudios::Yard::Data::SeeTag
      .new(native: tag, registry: ::YARD::Registry)
      .as_json
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:native, :registry)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'name'              => module_object.name,
        'slug'              => module_object.slug,
        'files'             => module_object.files,
        'short_description' => module_object.short_description
      }
    end

    it { expect(module_object).to respond_to(:as_json).with(0).arguments }

    it { expect(module_object.as_json).to be == expected }

    wrap_context 'using fixture', 'with class attributes' do
      let(:expected) do
        super().merge('class_attributes' => module_object.class_attributes)
      end

      it { expect(module_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with class methods' do
      let(:expected) do
        super().merge('class_methods' => module_object.class_methods)
      end

      it { expect(module_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with complex name' do
      let(:module_name) { 'SpaceAndTime' }

      it { expect(module_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with constants' do
      let(:expected) do
        super().merge('constants' => module_object.constants)
      end

      it { expect(module_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with defined classes' do
      let(:expected) do
        super().merge('defined_classes' => module_object.defined_classes)
      end

      it { expect(module_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with defined modules' do
      let(:expected) do
        super().merge('defined_modules' => module_object.defined_modules)
      end

      it { expect(module_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with extended modules' do
      let(:expected) do
        super().merge(
          'class_methods'    => module_object.class_methods,
          'extended_modules' => module_object.extended_modules
        )
      end

      it { expect(module_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with full description' do
      let(:expected) do
        super().merge('description' => module_object.description)
      end

      it { expect(module_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with included modules' do
      let(:expected) do
        super().merge(
          'included_modules' => module_object.included_modules,
          'instance_methods' => module_object.instance_methods
        )
      end

      it { expect(module_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with instance attributes' do
      let(:expected) do
        super().merge(
          'instance_attributes' => module_object.instance_attributes
        )
      end

      it { expect(module_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with instance methods' do
      let(:expected) do
        super().merge('instance_methods' => module_object.instance_methods)
      end

      it { expect(module_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'metadata/with everything' do
      let(:expected) do
        super().merge('metadata' => module_object.metadata)
      end

      it { expect(module_object.as_json).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        super().merge(
          'class_attributes'    => module_object.class_attributes,
          'class_methods'       => module_object.class_methods,
          'constants'           => module_object.constants,
          'defined_classes'     => module_object.defined_classes,
          'defined_modules'     => module_object.defined_modules,
          'description'         => module_object.description,
          'extended_modules'    => module_object.extended_modules,
          'included_modules'    => module_object.included_modules,
          'instance_attributes' => module_object.instance_attributes,
          'instance_methods'    => module_object.instance_methods,
          'metadata'            => module_object.metadata
        )
      end

      it { expect(module_object.as_json).to deep_match expected }
    end
  end

  describe '#class_attributes' do
    include_examples 'should define reader', :class_attributes, []

    wrap_context 'using fixture', 'with class attributes' do
      let(:expected) do
        [
          {
            'name'  => 'curvature',
            'read'  => true,
            'write' => true
          },
          {
            'name'  => 'gravity',
            'read'  => true,
            'write' => false
          }
        ]
      end

      it { expect(module_object.class_attributes).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'name'  => 'curvature',
            'read'  => true,
            'write' => true
          },
          {
            'name'  => 'gravity',
            'read'  => true,
            'write' => false
          }
        ]
      end

      it { expect(module_object.class_attributes).to be == expected }
    end
  end

  describe '#class_methods' do
    include_examples 'should define reader', :class_methods, []

    wrap_context 'using fixture', 'with class methods' do
      let(:expected) { %w[calculate_isp plot_trajectory] }

      it { expect(module_object.class_methods).to be == expected }
    end

    wrap_context 'using fixture', 'with extended modules' do
      let(:expected) { %w[dew_point temperature] }

      it { expect(module_object.class_methods).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) { %w[calculate_isp dew_point plot_trajectory temperature] }

      it { expect(module_object.class_methods).to be == expected }
    end
  end

  describe '#constants' do
    include_examples 'should define reader', :constants, []

    wrap_context 'using fixture', 'with constants' do
      let(:expected) { %w[ELDRITCH SQUAMOUS] }

      it { expect(module_object.constants).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) { %w[ELDRITCH SQUAMOUS] }

      it { expect(module_object.constants).to be == expected }
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

      it { expect(module_object.defined_classes).to be == expected }
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

      it { expect(module_object.defined_classes).to be == expected }
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

      it { expect(module_object.defined_modules).to be == expected }
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

      it { expect(module_object.defined_modules).to be == expected }
    end
  end

  describe '#description' do
    include_examples 'should define reader', :description, nil

    wrap_context 'using fixture', 'undocumented' do
      it { expect(module_object.description).to be nil }
    end

    wrap_context 'using fixture', 'with full description' do
      let(:expected) do
        <<~TEXT.strip
          This module has a full description. It is comprised of a short description,
          followed by a multiline explanation, a list, and an essay cliche.

          - This is a description item.
          - This is another description item.

          In conclusion, space is a land of contrasts.
        TEXT
      end

      it { expect(module_object.description).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        <<~TEXT.strip
          This module has a full description. It is comprised of a short description,
          followed by a multiline explanation, a list, and an essay cliche.

          - This is a description item.
          - This is another description item.

          In conclusion, space is a land of contrasts.
        TEXT
      end

      it { expect(module_object.description).to be == expected }
    end
  end

  describe '#extended_modules' do
    include_examples 'should define reader', :extended_modules, []

    wrap_context 'using fixture', 'with extended modules' do
      let(:expected) do
        [
          {
            'name' => 'Revenge',
            'slug' => 'revenge'
          },
          {
            'name' => 'WeatherEffects',
            'slug' => 'weather-effects'
          }
        ]
      end

      it { expect(module_object.extended_modules).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'name' => 'Revenge',
            'slug' => 'revenge'
          },
          {
            'name' => 'WeatherEffects',
            'slug' => 'weather-effects'
          }
        ]
      end

      it { expect(module_object.extended_modules).to be == expected }
    end
  end

  describe '#files' do
    let(:expected) { [File.join('spec/fixtures/modules', fixture)] }

    include_examples 'should define reader', :files, -> { expected }

    context 'when the module is defined in multiple files' do
      let(:expected) do
        [
          *super(),
          'spec/fixtures/modules/with_constants.rb',
          'spec/fixtures/modules/with_full_description.rb'
        ]
      end

      before(:example) do
        YARD.parse('spec/fixtures/modules/with_constants.rb')
        YARD.parse('spec/fixtures/modules/with_full_description.rb')
      end

      it { expect(module_object.files).to be == expected }
    end
  end

  describe '#included_modules' do
    include_examples 'should define reader', :included_modules, []

    wrap_context 'using fixture', 'with included modules' do
      let(:expected) do
        [
          {
            'name' => 'Dimensions',
            'slug' => 'dimensions'
          },
          {
            'name' => 'HigherDimensions',
            'slug' => 'higher-dimensions'
          }
        ]
      end

      it { expect(module_object.included_modules).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        [
          {
            'name' => 'Dimensions',
            'slug' => 'dimensions'
          },
          {
            'name' => 'HigherDimensions',
            'slug' => 'higher-dimensions'
          }
        ]
      end

      it { expect(module_object.included_modules).to be == expected }
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

      it { expect(module_object.instance_attributes).to be == expected }
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

      it { expect(module_object.instance_attributes).to be == expected }
    end
  end

  describe '#instance_methods' do
    include_examples 'should define reader', :instance_methods, []

    wrap_context 'using fixture', 'with instance methods' do
      let(:expected) { %w[convert_mana summon_dark_lord] }

      it { expect(module_object.instance_methods).to be == expected }
    end

    wrap_context 'using fixture', 'with included modules' do
      let(:expected) { %w[cardinality] }

      it { expect(module_object.instance_methods).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      let(:expected) { %w[cardinality convert_mana summon_dark_lord] }

      it { expect(module_object.instance_methods).to be == expected }
    end
  end

  describe '#metadata' do
    include_examples 'should define reader', :metadata, {}

    wrap_context 'using fixture', 'metadata/with examples' do
      let(:expected) do
        {
          'examples' => [
            {
              'name' => '',
              'text' => '# This is an anonymous example.'
            },
            {
              'name' => '',
              'text' => '# This is another anonymous example.'
            },
            {
              'name' => 'Named Example',
              'text' => '# This is a named example.'
            }
          ]
        }
      end

      it { expect(module_object.metadata).to be == expected }
    end

    wrap_context 'using fixture', 'metadata/with notes' do
      let(:expected) do
        {
          'notes' => [
            'This is a note.',
            'This is another note.',
            'This makes a chord.'
          ]
        }
      end

      it { expect(module_object.metadata).to be == expected }
    end

    wrap_context 'using fixture', 'metadata/with see' do
      let(:see_tags) do
        native
          .tags
          .select { |tag| tag.tag_name == 'see' }
          .map { |tag| format_see_tag(tag) }
      end
      let(:expected) do
        { 'see' => see_tags }
      end

      it { expect(module_object.metadata).to be == expected }
    end

    wrap_context 'using fixture', 'metadata/with todos' do
      let(:expected) do
        {
          'todos' => [
            'Cut the blue wire.',
            'Cut the red wire.',
            'Remove the plutonium.'
          ]
        }
      end

      it { expect(module_object.metadata).to be == expected }
    end

    wrap_context 'using fixture', 'metadata/with everything' do
      let(:see_tags) do
        native
          .tags
          .select { |tag| tag.tag_name == 'see' }
          .map { |tag| format_see_tag(tag) }
      end
      let(:expected) do
        {
          'notes'    => [
            'This is a note.',
            'This is another note.',
            'This makes a chord.'
          ],
          'examples' => [
            {
              'name' => '',
              'text' => '# This is an anonymous example.'
            },
            {
              'name' => '',
              'text' => '# This is another anonymous example.'
            },
            {
              'name' => 'Named Example',
              'text' => '# This is a named example.'
            }
          ],
          'see'      => see_tags,
          'todos'    => [
            'Cut the blue wire.',
            'Cut the red wire.',
            'Remove the plutonium.'
          ]
        }
      end

      it { expect(module_object.metadata).to be == expected }
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
          'notes'    => [
            'This is a note.',
            'This is another note.',
            'This makes a chord.'
          ],
          'examples' => [
            {
              'name' => '',
              'text' => '# This is an anonymous example.'
            },
            {
              'name' => '',
              'text' => '# This is another anonymous example.'
            },
            {
              'name' => 'Named Example',
              'text' => '# This is a named example.'
            }
          ],
          'see'      => see_tags,
          'todos'    => [
            'Cut the blue wire.',
            'Cut the red wire.',
            'Remove the plutonium.'
          ]
        }
      end

      it { expect(module_object.metadata).to be == expected }
    end
  end

  describe '#name' do
    include_examples 'should define reader', :name, 'Space'

    wrap_context 'using fixture', 'with complex name' do
      let(:module_name) { 'SpaceAndTime' }

      it { expect(module_object.name).to be == module_name }
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

  describe '#short_description' do
    let(:expected) { 'This module is out of this world.' }

    include_examples 'should define reader', :short_description, -> { expected }

    wrap_context 'using fixture', 'undocumented' do
      it { expect(module_object.short_description).to be == '' }
    end

    wrap_context 'using fixture', 'with full description' do
      it { expect(module_object.short_description).to be == expected }
    end

    wrap_context 'using fixture', 'with everything' do
      it { expect(module_object.short_description).to be == expected }
    end
  end

  describe '#slug' do
    include_examples 'should define reader', :slug, 'space'

    wrap_context 'using fixture', 'with complex name' do
      let(:module_name) { 'SpaceAndTime' }

      it { expect(module_object.slug).to be == 'space-and-time' }
    end
  end
end
