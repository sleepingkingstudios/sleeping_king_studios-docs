# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tags'

require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::SeeTags do
  include Spec::Support::Fixtures

  describe '.build' do
    include_context 'with fixture files', 'see_tags'

    shared_examples 'should wrap the tag with' do |expected_class_name|
      subject(:see_tag) do
        described_class.build(native: native, parent: parent)
      end

      let(:expected_class) { described_class.const_get(expected_class_name) }

      it { expect(see_tag).to be_a expected_class }

      it { expect(see_tag.send(:native)).to be native }

      it { expect(see_tag.parent).to be parent }
    end

    let(:fixture) { 'plain_text.rb' }
    let(:parent)  { YARD::Registry.find { |obj| obj.title == 'Space' } }
    let(:native)  { parent.tags.find { |tag| tag.tag_name == 'see' } }

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:build)
        .with(0).arguments
        .and_keywords(:native, :parent)
    end

    include_examples 'should wrap the tag with', 'TextTag'

    wrap_context 'using fixture', 'ambiguous definition' do
      include_examples 'should wrap the tag with', 'DefinitionTag'
    end

    wrap_context 'using fixture', 'absolute constant' do
      include_examples 'should wrap the tag with', 'ConstantTag'
    end

    wrap_context 'using fixture', 'absolute definition' do
      include_examples 'should wrap the tag with', 'DefinitionTag'
    end

    wrap_context 'using fixture', 'class attribute reader' do
      include_examples 'should wrap the tag with', 'ClassMethodTag'
    end

    wrap_context 'using fixture', 'class attribute writer' do
      include_examples 'should wrap the tag with', 'ClassMethodTag'
    end

    wrap_context 'using fixture', 'class method' do
      include_examples 'should wrap the tag with', 'ClassMethodTag'
    end

    wrap_context 'using fixture', 'class method predicate' do
      include_examples 'should wrap the tag with', 'ClassMethodTag'
    end

    wrap_context 'using fixture', 'class method with text' do
      include_examples 'should wrap the tag with', 'ClassMethodTag'
    end

    wrap_context 'using fixture', 'class method writer' do
      include_examples 'should wrap the tag with', 'ClassMethodTag'
    end

    wrap_context 'using fixture', 'constant' do
      include_examples 'should wrap the tag with', 'ConstantTag'
    end

    wrap_context 'using fixture', 'constant with text' do
      include_examples 'should wrap the tag with', 'ConstantTag'
    end

    wrap_context 'using fixture', 'definition' do
      include_examples 'should wrap the tag with', 'DefinitionTag'
    end

    wrap_context 'using fixture', 'definition with text' do
      include_examples 'should wrap the tag with', 'DefinitionTag'
    end

    wrap_context 'using fixture', 'empty' do
      include_examples 'should wrap the tag with', 'TextTag'
    end

    wrap_context 'using fixture', 'instance attribute reader' do
      include_examples 'should wrap the tag with', 'InstanceMethodTag'
    end

    wrap_context 'using fixture', 'instance attribute writer' do
      include_examples 'should wrap the tag with', 'InstanceMethodTag'
    end

    wrap_context 'using fixture', 'instance method' do
      include_examples 'should wrap the tag with', 'InstanceMethodTag'
    end

    wrap_context 'using fixture', 'instance method predicate' do
      include_examples 'should wrap the tag with', 'InstanceMethodTag'
    end

    wrap_context 'using fixture', 'instance method with text' do
      include_examples 'should wrap the tag with', 'InstanceMethodTag'
    end

    wrap_context 'using fixture', 'instance method writer' do
      include_examples 'should wrap the tag with', 'InstanceMethodTag'
    end

    wrap_context 'using fixture', 'legacy class method' do
      include_examples 'should wrap the tag with', 'ClassMethodTag'
    end

    wrap_context 'using fixture', 'link' do
      include_examples 'should wrap the tag with', 'LinkTag'
    end

    wrap_context 'using fixture', 'link with text' do
      include_examples 'should wrap the tag with', 'LinkTag'
    end

    wrap_context 'using fixture', 'nested class method' do
      include_examples 'should wrap the tag with', 'ClassMethodTag'
    end

    wrap_context 'using fixture', 'nested constant' do
      include_examples 'should wrap the tag with', 'ConstantTag'
    end

    wrap_context 'using fixture', 'nested definition' do
      include_examples 'should wrap the tag with', 'DefinitionTag'
    end

    wrap_context 'using fixture', 'nested instance method' do
      include_examples 'should wrap the tag with', 'InstanceMethodTag'
    end

    wrap_context 'using fixture', 'relative class method' do
      include_examples 'should wrap the tag with', 'ClassMethodTag'
    end

    wrap_context 'using fixture', 'relative constant' do
      include_examples 'should wrap the tag with', 'ConstantTag'
    end

    wrap_context 'using fixture', 'relative definition' do
      include_examples 'should wrap the tag with', 'DefinitionTag'
    end

    wrap_context 'using fixture', 'relative instance method' do
      include_examples 'should wrap the tag with', 'InstanceMethodTag'
    end

    wrap_context 'using fixture', 'scoped class method' do
      include_examples 'should wrap the tag with', 'ClassMethodTag'
    end

    wrap_context 'using fixture', 'scoped constant' do
      include_examples 'should wrap the tag with', 'ConstantTag'
    end

    wrap_context 'using fixture', 'scoped definition' do
      include_examples 'should wrap the tag with', 'DefinitionTag'
    end

    wrap_context 'using fixture', 'scoped instance method' do
      include_examples 'should wrap the tag with', 'InstanceMethodTag'
    end

    wrap_context 'using fixture', 'unmatched class method' do
      include_examples 'should wrap the tag with', 'ClassMethodTag'
    end

    wrap_context 'using fixture', 'unmatched constant' do
      include_examples 'should wrap the tag with', 'ConstantTag'
    end

    wrap_context 'using fixture', 'unmatched definition' do
      include_examples 'should wrap the tag with', 'DefinitionTag'
    end

    wrap_context 'using fixture', 'unmatched instance method' do
      include_examples 'should wrap the tag with', 'InstanceMethodTag'
    end
  end
end
