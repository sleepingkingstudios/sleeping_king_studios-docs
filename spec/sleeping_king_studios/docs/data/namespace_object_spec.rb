# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/namespace_object'

require 'support/deferred/data_examples'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Docs::Data::NamespaceObject do
  include Spec::Support::Deferred::DataExamples
  include Spec::Support::Fixtures

  subject(:namespace) { described_class.new(native:) }

  include_context 'with fixture files', 'namespaces'

  let(:fixture) { 'empty.rb' }
  let(:native)  { YARD::Registry.root }
  let(:expected_json) do
    {
      'name' => namespace.name,
      'slug' => namespace.slug,
      'type' => namespace.type
    }
  end

  include_deferred 'should be a data object'

  include_deferred 'should implement the namespace methods',
    include_mixins: false

  describe '#as_json' do
    wrap_context 'using fixture', 'with everything' do
      let(:expected) do
        {
          'name'                => namespace.name,
          'slug'                => namespace.slug,
          'type'                => namespace.type,
          'class_attributes'    => namespace.class_attributes,
          'class_methods'       => namespace.class_methods,
          'constants'           => namespace.constants,
          'defined_classes'     => namespace.defined_classes,
          'defined_modules'     => namespace.defined_modules,
          'instance_attributes' => namespace.instance_attributes,
          'instance_methods'    => namespace.instance_methods
        }
      end

      it { expect(namespace.as_json).to deep_match expected }
    end
  end

  describe '#name' do
    include_examples 'should define reader', :name, ''
  end

  describe '#slug' do
    include_examples 'should define reader', :slug, ''
  end

  describe '#type' do
    include_examples 'should define reader', :type, 'namespace'
  end
end
