# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'support/deferred'

module Spec::Support::Deferred
  # Deferred examples for testing data objects.
  module DataExamples # rubocop:disable Metrics/ModuleLength
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should be a data object' do |skip_constructor: false|
      before(:context) do
        ::YARD::Registry.clear

        SleepingKingStudios::Docs::Yard::Registry.clear
      end

      after(:example) do
        ::YARD::Registry.clear

        SleepingKingStudios::Docs::Yard::Registry.clear
      end

      unless skip_constructor
        describe '.new' do
          it 'should define the constructor' do
            expect(described_class)
              .to be_constructible
              .with(0).arguments
              .and_keywords(:native)
          end
        end
      end

      describe '#as_json' do
        let(:expected_json) do
          defined?(super()) ? super() : {}
        end

        it { expect(subject).to respond_to(:as_json).with(0).arguments }

        it { expect(subject.as_json).to be == expected_json }
      end

      describe '#native' do
        include_examples 'should define private reader', :native, -> { native }
      end

      describe '#registry' do
        include_examples 'should define private reader',
          :registry,
          -> { be == [::YARD::Registry.root, *::YARD::Registry.to_a] }

        context 'with a mocked registry' do
          let(:mock_registry) do
            [::YARD::Registry.root]
          end

          before(:example) do
            allow(SleepingKingStudios::Docs::Yard::Registry)
              .to receive(:instance)
              .and_return(mock_registry)
          end

          it { expect(subject.send(:registry)).to be == mock_registry }
        end
      end
    end

    deferred_examples 'should be a describable object' do | # rubocop:disable Metrics/ParameterLists
      basic_name:,
      complex_name:,
      description:,
      scoped_name:,
      data_path: true,
      separator: '::'
    |
      describe '#as_json' do
        let(:expected) { expected_json }

        wrap_context 'using fixture', 'undocumented' do
          it { expect(subject.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with full description' do
          let(:expected) do
            super().merge('description' => subject.description)
          end

          it { expect(subject.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with metadata' do
          let(:expected) do
            super().merge('metadata' => subject.metadata)
          end

          it { expect(subject.as_json).to be == expected }
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

            it { expect(subject.data_path).to be == expected }
          end

          wrap_context 'using fixture', 'with scoped name' do
            let(:fixture_name) { scoped_name }
            let(:expected) do
              scoped_name
                .split(separator)
                .map { |str| tools.str.underscore(str).tr('_', '-') }
                .join('/')
            end

            it { expect(subject.data_path).to be == expected }
          end
        end
      end

      describe '#description' do
        include_examples 'should define reader', :description, nil

        wrap_context 'using fixture', 'undocumented' do
          it { expect(subject.description).to be nil }
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

          it { expect(subject.description.class).to be String }

          it { expect(subject.description).to be == expected }
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

          it { expect(subject.description).to be == expected }
        end
      end

      describe '#metadata' do
        include_examples 'should define reader', :metadata, {}

        def format_see_tag(tag)
          SleepingKingStudios::Docs::Data::SeeTags
            .build(native: tag, parent: native)
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

          it { expect(subject.metadata).to be == expected }
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

          it { expect(subject.metadata).to be == expected }
        end
      end

      describe '#name' do
        include_examples 'should define reader', :name, basic_name

        wrap_context 'using fixture', 'with complex name' do
          let(:fixture_name) { complex_name }

          it { expect(subject.name).to be == complex_name }
        end

        wrap_context 'using fixture', 'with scoped name' do
          let(:fixture_name) { scoped_name }

          it { expect(subject.name).to be == scoped_name }
        end
      end

      describe '#short_description' do
        let(:expected) { description }

        include_examples 'should define reader',
          :short_description,
          -> { expected }

        it { expect(subject.short_description.class).to be String }

        wrap_context 'using fixture', 'undocumented' do
          it { expect(subject.short_description).to be == '' }
        end

        wrap_context 'using fixture', 'with full description' do
          it { expect(subject.short_description).to be == expected }
        end

        wrap_context 'using fixture', 'with everything' do
          it { expect(subject.short_description).to be == expected }
        end
      end

      describe '#slug' do
        let(:expected) do
          fixture_name
            .split(separator)
            .last
            .then { |str| tools.str.underscore(str) }
            .tr('_', '-')
        end

        def tools
          SleepingKingStudios::Tools::Toolbelt.instance
        end

        include_examples 'should define reader', :slug, -> { be == expected }

        wrap_context 'using fixture', 'with complex name' do
          let(:fixture_name) { complex_name }

          it { expect(subject.slug).to be == expected }
        end

        wrap_context 'using fixture', 'with scoped name' do
          let(:fixture_name) { scoped_name }

          it { expect(subject.slug).to be == expected }
        end
      end
    end

    deferred_examples 'should be a type object' do
      shared_context 'when the definition exists' do
        let(:query) do
          instance_double(
            SleepingKingStudios::Docs::Yard::RegistryQuery,
            definition_exists?: true
          )
        end

        before(:example) do
          allow(SleepingKingStudios::Docs::Yard::RegistryQuery)
            .to receive(:new)
            .and_return(query)
        end
      end

      before(:context) do
        ::YARD::Registry.clear

        SleepingKingStudios::Docs::Yard::Registry.clear
      end

      after(:example) do
        ::YARD::Registry.clear

        SleepingKingStudios::Docs::Yard::Registry.clear
      end

      describe '#==' do
        define_method :type_double do |mock_class, json|
          mock = instance_double(
            SleepingKingStudios::Docs::Data::Types::Type,
            as_json: json
          )

          allow(mock).to receive(:instance_of?) do |expected_class|
            expected_class == mock_class
          end

          mock
        end

        describe 'with nil' do
          it { expect(type == nil).to be false } # rubocop:disable Style/NilComparison
        end

        describe 'with an object' do
          it { expect(type == Object.new.freeze).to be false }
        end

        describe 'with a type with non-matching class' do
          let(:other) do
            type_double(Spec::CustomType, subject.as_json)
          end

          example_class 'Spec::CustomType',
            SleepingKingStudios::Docs::Data::Types::Type

          it { expect(type == other).to be false }
        end

        describe 'with a type with non-matching json' do
          let(:other) do
            type_double(subject.class, { 'name' => 'Space' })
          end

          it { expect(type == other).to be false }
        end

        describe 'with a type with matching class and json' do
          let(:other) do
            type_double(subject.class, subject.as_json)
          end

          it { expect(type == other).to be true }
        end
      end

      describe '#as_json' do
        let(:expected) do
          next expected_json if defined?(expected_json)

          { 'name' => subject.name }
        end

        it { expect(type).to respond_to(:as_json).with(0).arguments }

        it { expect(subject.as_json).to be == expected }

        wrap_context 'when the definition exists' do
          let(:expected) do
            super().merge('path' => subject.path)
          end

          it { expect(subject.as_json).to be == expected }
        end

        context 'when initialized with a class method name' do
          let(:name) { '.build' }

          it { expect(subject.as_json).to be == expected }
        end

        context 'when initialized with an instance method name' do
          let(:name) { '#call' }

          it { expect(subject.as_json).to be == expected }
        end

        context 'when initialized with a literal' do
          let(:name) { 'nil' }

          it { expect(subject.as_json).to be == expected }
        end

        context 'when initialized with a scoped name' do
          let(:name) { 'Cosmos::LocalDimension::SpaceAndTime' }

          it { expect(subject.as_json).to be == expected }

          wrap_context 'when the definition exists' do
            let(:expected) do
              super().merge('path' => subject.path)
            end

            it { expect(subject.as_json).to be == expected }
          end
        end
      end

      describe '#exists?' do
        let(:query) do
          instance_double(
            SleepingKingStudios::Docs::Yard::RegistryQuery,
            definition_exists?: false
          )
        end

        before(:example) do
          allow(SleepingKingStudios::Docs::Yard::RegistryQuery)
            .to receive(:new)
            .and_return(query)
        end

        include_examples 'should define predicate', :exists?, false

        it 'should query the registry' do
          subject.exists?

          expect(query)
            .to have_received(:definition_exists?)
            .with(subject.name)
        end

        context 'when the definition exists' do
          before(:example) do
            allow(query).to receive(:definition_exists?).and_return(true)
          end

          it { expect(subject.exists?).to be true }
        end

        context 'when initialized with a class method name' do
          let(:name) { '.build' }

          it { expect(subject.exists?).to be false }

          it 'should not query the registry' do
            subject.exists?

            expect(query)
              .not_to have_received(:definition_exists?)
              .with(subject.name)
          end
        end

        context 'when initialized with an instance method name' do
          let(:name) { '#call' }

          it { expect(subject.exists?).to be false }

          it 'should not query the registry' do
            subject.exists?

            expect(query)
              .not_to have_received(:definition_exists?)
              .with(subject.name)
          end
        end

        context 'when initialized with a literal' do
          let(:name) { 'nil' }

          it { expect(subject.exists?).to be false }

          it 'should not query the registry' do
            subject.exists?

            expect(query)
              .not_to have_received(:definition_exists?)
              .with(subject.name)
          end
        end
      end

      describe '#literal?' do
        include_examples 'should define predicate', :literal?, false

        context 'when initialized with a class method name' do
          let(:name) { '.build' }

          it { expect(subject.literal?).to be false }
        end

        context 'when initialized with an instance method name' do
          let(:name) { '#call' }

          it { expect(subject.literal?).to be false }
        end

        context 'when initialized with a literal' do
          let(:name) { 'nil' }

          it { expect(subject.literal?).to be true }
        end
      end

      describe '#method?' do
        include_examples 'should define predicate', :method?, false

        context 'when initialized with a class method name' do
          let(:name) { '.build' }

          it { expect(subject.method?).to be true }
        end

        context 'when initialized with an instance method name' do
          let(:name) { '#call' }

          it { expect(subject.method?).to be true }
        end

        context 'when initialized with a literal' do
          let(:name) { 'nil' }

          it { expect(subject.method?).to be false }
        end
      end

      describe '#name' do
        include_examples 'should define reader', :name, -> { name }

        context 'when initialized with a class method name' do
          let(:name) { '.build' }

          it { expect(subject.name).to be == name }
        end

        context 'when initialized with an instance method name' do
          let(:name) { '#call' }

          it { expect(subject.name).to be == name }
        end

        context 'when initialized with a literal' do
          let(:name) { 'nil' }

          it { expect(subject.name).to be == name }
        end

        context 'when initialized with a scoped name' do
          let(:name) { 'Cosmos::LocalDimension::SpaceAndTime' }

          it { expect(subject.name).to be == name }
        end
      end

      describe '#path' do
        include_examples 'should define reader', :path, nil

        context 'when initialized with a class method name' do
          let(:name) { '.build' }

          it { expect(subject.path).to be nil }
        end

        context 'when initialized with an instance method name' do
          let(:name) { '#call' }

          it { expect(subject.path).to be nil }
        end

        context 'when initialized with a literal' do
          let(:name) { 'nil' }

          it { expect(subject.path).to be nil }
        end

        wrap_context 'when the definition exists' do
          it { expect(subject.path).to be == 'rocket' }
        end

        context 'when initialized with a scoped name' do
          let(:name) { 'Cosmos::LocalDimension::SpaceAndTime' }

          it { expect(subject.path).to be nil }

          wrap_context 'when the definition exists' do
            let(:expected) { 'cosmos/local-dimension/space-and-time' }

            it { expect(subject.path).to be == expected }
          end
        end
      end

      describe '#registry' do
        include_examples 'should define private reader',
          :registry,
          -> { be == [::YARD::Registry.root, *::YARD::Registry.to_a] }

        context 'with a mocked registry' do
          let(:mock_registry) do
            [::YARD::Registry.root]
          end

          before(:example) do
            allow(SleepingKingStudios::Docs::Yard::Registry)
              .to receive(:instance)
              .and_return(mock_registry)
          end

          it { expect(subject.send(:registry)).to be == mock_registry }
        end
      end
    end

    deferred_examples 'should be a @see tag object' do
      include_deferred 'should be a data object', skip_constructor: true

      describe '.new' do
        it 'should define the constructor' do
          expect(described_class)
            .to be_constructible
            .with(0).arguments
            .and_keywords(:native, :parent)
        end
      end

      describe '#parent' do
        include_examples 'should define reader', :parent, -> { parent }
      end
    end

    deferred_examples 'should implement the namespace methods' \
    do |include_mixins: true, inherit_mixins: false|
      describe '#as_json' do
        let(:expected) { expected_json }

        wrap_context 'using fixture', 'with class attributes' do
          let(:expected) do
            super().merge('class_attributes' => subject.class_attributes)
          end

          it { expect(subject.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with class methods' do
          let(:expected) do
            super().merge('class_methods' => subject.class_methods)
          end

          it { expect(subject.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with constants' do
          let(:expected) do
            super().merge('constants' => subject.constants)
          end

          it { expect(subject.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with defined classes' do
          let(:expected) do
            super().merge('defined_classes' => subject.defined_classes)
          end

          it { expect(subject.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with defined modules' do
          let(:expected) do
            super().merge('defined_modules' => subject.defined_modules)
          end

          it { expect(subject.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with instance attributes' do
          let(:expected) do
            super().merge(
              'instance_attributes' => subject.instance_attributes
            )
          end

          it { expect(subject.as_json).to be == expected }
        end

        wrap_context 'using fixture', 'with instance methods' do
          let(:expected) do
            super().merge('instance_methods' => subject.instance_methods)
          end

          it { expect(subject.as_json).to be == expected }
        end
      end

      describe '#class_attributes' do
        def relative_path(path)
          return path if subject.name.empty? || subject.name == 'root'

          "#{tools.str.underscore(subject.name)}/#{path}"
        end

        include_examples 'should define reader', :class_attributes, []

        wrap_context 'using fixture', 'with class attributes' do
          let(:expected) do
            [
              {
                'name'      => 'gravity',
                'read'      => true,
                'write'     => false,
                'path'      => relative_path('c-gravity'),
                'slug'      => 'gravity',
                'inherited' => false
              },
              {
                'name'      => 'sandbox_mode',
                'read'      => true,
                'write'     => true,
                'path'      => relative_path('c-sandbox-mode'),
                'slug'      => 'sandbox-mode',
                'inherited' => false
              },
              {
                'name'      => 'secret_key',
                'read'      => false,
                'write'     => true,
                'path'      => relative_path('c-secret-key='),
                'slug'      => 'secret-key=',
                'inherited' => false
              }
            ]
          end

          it { expect(subject.class_attributes).to be == expected }
        end

        if include_mixins
          wrap_context 'using fixture', 'with extended modules' do
            let(:expected) do
              [
                {
                  'name'      => 'pressure',
                  'read'      => true,
                  'write'     => true,
                  'path'      => 'phenomena/weather-effects/i-pressure',
                  'slug'      => 'pressure',
                  'inherited' => true
                }
              ]
            end

            it { expect(subject.class_attributes).to deep_match expected }
          end
        end

        if inherit_mixins
          wrap_context 'using fixture', 'with inherited classes' do
            let(:expected) do
              [
                {
                  'name'      => 'blueprints',
                  'read'      => true,
                  'write'     => true,
                  'path'      => 'engineering/c-blueprints',
                  'slug'      => 'blueprints',
                  'inherited' => true
                }
              ]
            end

            it { expect(subject.class_attributes).to deep_match expected }
          end
        end

        wrap_context 'using fixture', 'with everything' do
          let(:expected) do
            ary = [
              {
                'name'      => 'gravity',
                'read'      => true,
                'write'     => false,
                'path'      => relative_path('c-gravity'),
                'slug'      => 'gravity',
                'inherited' => false
              },
              {
                'name'      => 'sandbox_mode',
                'read'      => true,
                'write'     => true,
                'path'      => relative_path('c-sandbox-mode'),
                'slug'      => 'sandbox-mode',
                'inherited' => false
              },
              {
                'name'      => 'secret_key',
                'read'      => false,
                'write'     => true,
                'path'      => relative_path('c-secret-key='),
                'slug'      => 'secret-key=',
                'inherited' => false
              }
            ]

            if include_mixins
              ary += [
                {
                  'name'      => 'pressure',
                  'read'      => true,
                  'write'     => true,
                  'path'      => 'phenomena/weather-effects/i-pressure',
                  'slug'      => 'pressure',
                  'inherited' => true
                }
              ]
            end

            if inherit_mixins
              ary += [
                {
                  'name'      => 'blueprints',
                  'read'      => true,
                  'write'     => true,
                  'path'      => 'engineering/c-blueprints',
                  'slug'      => 'blueprints',
                  'inherited' => true
                }
              ]
            end

            ary.sort_by { |hsh| hsh['name'] }
          end

          it { expect(subject.class_attributes).to be == expected }
        end
      end

      describe '#class_methods' do
        def relative_path(path)
          return path if subject.name.empty? || subject.name == 'root'

          "#{tools.str.underscore(subject.name)}/#{path}"
        end

        include_examples 'should define reader', :class_methods, []

        wrap_context 'using fixture', 'with class methods' do
          let(:expected) do
            [
              {
                'name'      => 'calculate_isp',
                'path'      => relative_path('c-calculate-isp'),
                'slug'      => 'calculate-isp',
                'inherited' => false
              },
              {
                'name'      => 'plot_trajectory',
                'path'      => relative_path('c-plot-trajectory'),
                'slug'      => 'plot-trajectory',
                'inherited' => false
              }
            ]
          end

          it { expect(subject.class_methods).to be == expected }
        end

        if include_mixins
          wrap_context 'using fixture', 'with extended modules' do
            let(:expected) do
              [
                {
                  'name'      => 'dew_point',
                  'path'      => 'atmosphere/i-dew-point',
                  'slug'      => 'dew-point',
                  'inherited' => true
                },
                {
                  'name'      => 'temperature',
                  'path'      => 'phenomena/weather-effects/i-temperature',
                  'slug'      => 'temperature',
                  'inherited' => true
                }
              ]
            end

            it { expect(subject.class_methods).to be == expected }
          end
        end

        if inherit_mixins
          wrap_context 'using fixture', 'with inherited classes' do
            let(:expected) do
              [
                {
                  'name'      => 'design',
                  'path'      => 'engineering/c-design',
                  'slug'      => 'design',
                  'inherited' => true
                }
              ]
            end

            it { expect(subject.class_methods).to be == expected }
          end
        end

        wrap_context 'using fixture', 'with everything' do
          let(:expected) do
            ary = [
              {
                'name'      => 'calculate_isp',
                'path'      => relative_path('c-calculate-isp'),
                'slug'      => 'calculate-isp',
                'inherited' => false
              },
              {
                'name'      => 'plot_trajectory',
                'path'      => relative_path('c-plot-trajectory'),
                'slug'      => 'plot-trajectory',
                'inherited' => false
              }
            ]

            if include_mixins
              ary += [
                {
                  'name'      => 'dew_point',
                  'path'      => 'atmosphere/i-dew-point',
                  'slug'      => 'dew-point',
                  'inherited' => true
                },
                {
                  'name'      => 'temperature',
                  'path'      => 'phenomena/weather-effects/i-temperature',
                  'slug'      => 'temperature',
                  'inherited' => true
                }
              ]
            end

            if inherit_mixins
              ary += [
                {
                  'name'      => 'design',
                  'path'      => 'engineering/c-design',
                  'slug'      => 'design',
                  'inherited' => true
                }
              ]
            end

            ary.sort_by { |hsh| hsh['name'] }
          end

          it { expect(subject.class_methods).to be == expected }
        end
      end

      describe '#constants' do
        include_examples 'should define reader', :constants, []

        wrap_context 'using fixture', 'with constants' do
          let(:base_path) do
            return '' unless subject.respond_to?(:data_path)

            return '' if subject.data_path == 'root'

            "#{subject.data_path}/"
          end
          let(:expected) do
            [
              {
                'name'      => 'ELDRITCH',
                'path'      => "#{base_path}eldritch",
                'slug'      => 'eldritch',
                'inherited' => false
              },
              {
                'name'      => 'SQUAMOUS',
                'path'      => "#{base_path}squamous",
                'slug'      => 'squamous',
                'inherited' => false
              }
            ]
          end

          it { expect(subject.constants).to be == expected }
        end

        if include_mixins
          wrap_context 'using fixture', 'with included modules' do
            let(:expected) do
              [
                {
                  'name'      => 'LENGTH',
                  'path'      => 'dimensions/length',
                  'slug'      => 'length',
                  'inherited' => true
                }
              ]
            end

            it { expect(subject.constants).to be == expected }
          end
        end

        if inherit_mixins
          wrap_context 'using fixture', 'with inherited classes' do
            let(:expected) do
              [
                {
                  'name'      => 'MODEL',
                  'path'      => 'physics/rocket-science/model',
                  'slug'      => 'model',
                  'inherited' => true
                }
              ]
            end

            it { expect(subject.constants).to be == expected }
          end
        end

        wrap_context 'using fixture', 'with everything' do
          let(:base_path) do
            return '' unless subject.respond_to?(:data_path)

            return '' if subject.data_path == 'root'

            "#{subject.data_path}/"
          end
          let(:expected) do
            ary = [
              {
                'name'      => 'ELDRITCH',
                'path'      => "#{base_path}eldritch",
                'slug'      => 'eldritch',
                'inherited' => false
              },
              {
                'name'      => 'SQUAMOUS',
                'path'      => "#{base_path}squamous",
                'slug'      => 'squamous',
                'inherited' => false
              }
            ]

            if include_mixins
              ary += [
                {
                  'name'      => 'LENGTH',
                  'path'      => 'dimensions/length',
                  'slug'      => 'length',
                  'inherited' => true
                }
              ]
            end

            if inherit_mixins
              ary += [
                {
                  'name'      => 'MODEL',
                  'path'      => 'physics/rocket-science/model',
                  'slug'      => 'model',
                  'inherited' => true
                }
              ]
            end

            ary.sort_by { |hsh| hsh['name'] }
          end

          it { expect(subject.constants).to be == expected }
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

          it { expect(subject.defined_classes).to be == expected }
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

          it { expect(subject.defined_classes).to be == expected }
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

          it { expect(subject.defined_modules).to be == expected }
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

          it { expect(subject.defined_modules).to be == expected }
        end
      end

      describe '#instance_attributes' do
        def relative_path(path)
          return path if subject.name.empty? || subject.name == 'root'

          "#{tools.str.underscore(subject.name)}/#{path}"
        end

        include_examples 'should define reader', :instance_attributes, []

        if include_mixins
          wrap_context 'using fixture', 'with included modules' do
            let(:expected) do
              [
                {
                  'name'      => 'depth',
                  'read'      => true,
                  'write'     => true,
                  'path'      => 'measurement/i-depth',
                  'slug'      => 'depth',
                  'inherited' => true
                },
                {
                  'name'      => 'height',
                  'read'      => true,
                  'write'     => true,
                  'path'      => 'measurement/i-height',
                  'slug'      => 'height',
                  'inherited' => true
                },
                {
                  'name'      => 'width',
                  'read'      => true,
                  'write'     => true,
                  'path'      => 'measurement/i-width',
                  'slug'      => 'width',
                  'inherited' => true
                }
              ]
            end

            it { expect(subject.instance_attributes).to be == expected }
          end
        end

        if inherit_mixins
          wrap_context 'using fixture', 'with inherited classes' do
            let(:expected) do
              [
                {
                  'name'      => 'difficulty',
                  'read'      => true,
                  'write'     => true,
                  'path'      => 'physics/rocket-science/i-difficulty',
                  'slug'      => 'difficulty',
                  'inherited' => true
                }
              ]
            end

            it { expect(subject.instance_attributes).to be == expected }
          end
        end

        wrap_context 'using fixture', 'with instance attributes' do
          let(:expected) do
            [
              {
                'name'      => 'base_mana',
                'read'      => true,
                'write'     => false,
                'path'      => relative_path('i-base-mana'),
                'slug'      => 'base-mana',
                'inherited' => false
              },
              {
                'name'      => 'magic_enabled',
                'read'      => true,
                'write'     => true,
                'path'      => relative_path('i-magic-enabled'),
                'slug'      => 'magic-enabled',
                'inherited' => false
              },
              {
                'name'      => 'secret_formula',
                'read'      => false,
                'write'     => true,
                'path'      => relative_path('i-secret-formula='),
                'slug'      => 'secret-formula=',
                'inherited' => false
              }
            ]
          end

          it { expect(subject.instance_attributes).to be == expected }
        end

        wrap_context 'using fixture', 'with everything' do
          let(:expected) do
            ary = [
              {
                'name'      => 'base_mana',
                'read'      => true,
                'write'     => false,
                'path'      => relative_path('i-base-mana'),
                'slug'      => 'base-mana',
                'inherited' => false
              },
              {
                'name'      => 'magic_enabled',
                'read'      => true,
                'write'     => true,
                'path'      => relative_path('i-magic-enabled'),
                'slug'      => 'magic-enabled',
                'inherited' => false
              },
              {
                'name'      => 'secret_formula',
                'read'      => false,
                'write'     => true,
                'path'      => relative_path('i-secret-formula='),
                'slug'      => 'secret-formula=',
                'inherited' => false
              }
            ]

            if include_mixins
              ary += [
                {
                  'name'      => 'depth',
                  'read'      => true,
                  'write'     => true,
                  'path'      => 'measurement/i-depth',
                  'slug'      => 'depth',
                  'inherited' => true
                },
                {
                  'name'      => 'height',
                  'read'      => true,
                  'write'     => true,
                  'path'      => 'measurement/i-height',
                  'slug'      => 'height',
                  'inherited' => true
                },
                {
                  'name'      => 'width',
                  'read'      => true,
                  'write'     => true,
                  'path'      => 'measurement/i-width',
                  'slug'      => 'width',
                  'inherited' => true
                }
              ]
            end

            if inherit_mixins
              ary += [
                {
                  'name'      => 'difficulty',
                  'read'      => true,
                  'write'     => true,
                  'path'      => 'physics/rocket-science/i-difficulty',
                  'slug'      => 'difficulty',
                  'inherited' => true
                }
              ]
            end

            ary.sort_by { |hsh| hsh['name'] }
          end

          it { expect(subject.instance_attributes).to be == expected }
        end
      end

      describe '#instance_methods' do
        def relative_path(path)
          return path if subject.name.empty? || subject.name == 'root'

          "#{tools.str.underscore(subject.name)}/#{path}"
        end

        include_examples 'should define reader', :instance_methods, []

        if include_mixins
          wrap_context 'using fixture', 'with included modules' do
            let(:expected) do
              [
                {
                  'name'      => 'cardinality',
                  'path'      => 'dimensions/i-cardinality',
                  'slug'      => 'cardinality',
                  'inherited' => true
                }
              ]
            end

            it { expect(subject.instance_methods).to be == expected }
          end
        end

        if inherit_mixins
          wrap_context 'using fixture', 'with constructor' do
            let(:expected) do
              [
                {
                  'name'        => 'initialize',
                  'path'        => relative_path('i-initialize'),
                  'slug'        => 'initialize',
                  'constructor' => true,
                  'inherited'   => false
                }
              ]
            end

            it { expect(subject.instance_methods).to be == expected }
          end

          wrap_context 'using fixture', 'with inherited constructor' do
            let(:expected) do
              [
                {
                  'name'        => 'initialize',
                  'path'        => 'rocket-science/i-initialize',
                  'slug'        => 'initialize',
                  'constructor' => true,
                  'inherited'   => true
                }
              ]
            end

            it { expect(subject.instance_methods).to be == expected }
          end

          wrap_context 'using fixture', 'with inherited classes' do
            let(:expected) do
              [
                {
                  'name'      => 'project_orion',
                  'path'      => 'physics/rocket-science/i-project-orion',
                  'slug'      => 'project-orion',
                  'inherited' => true
                }
              ]
            end

            it { expect(subject.instance_methods).to be == expected }
          end
        end

        wrap_context 'using fixture', 'with instance methods' do
          let(:expected) do
            [
              {
                'name'      => 'convert_mana',
                'path'      => relative_path('i-convert-mana'),
                'slug'      => 'convert-mana',
                'inherited' => false
              },
              {
                'name'      => 'summon_dark_lord',
                'path'      => relative_path('i-summon-dark-lord'),
                'slug'      => 'summon-dark-lord',
                'inherited' => false
              }
            ]
          end

          it { expect(subject.instance_methods).to be == expected }
        end

        wrap_context 'using fixture', 'with everything' do
          let(:expected) do
            ary = [
              {
                'name'      => 'convert_mana',
                'path'      => relative_path('i-convert-mana'),
                'slug'      => 'convert-mana',
                'inherited' => false
              },
              {
                'name'      => 'summon_dark_lord',
                'path'      => relative_path('i-summon-dark-lord'),
                'slug'      => 'summon-dark-lord',
                'inherited' => false
              }
            ]

            if include_mixins
              ary += [
                {
                  'name'      => 'cardinality',
                  'path'      => 'dimensions/i-cardinality',
                  'slug'      => 'cardinality',
                  'inherited' => true
                }
              ]
            end

            if inherit_mixins
              ary += [
                {
                  'name'        => 'initialize',
                  'path'        => 'rocketry/i-initialize',
                  'slug'        => 'initialize',
                  'constructor' => true,
                  'inherited'   => false
                },
                {
                  'name'      => 'project_orion',
                  'path'      => 'physics/rocket-science/i-project-orion',
                  'slug'      => 'project-orion',
                  'inherited' => true
                }
              ]
            end

            ary.sort_by { |hsh| hsh['name'] }
          end

          it { expect(subject.instance_methods).to be == expected }
        end
      end
    end
  end
end
