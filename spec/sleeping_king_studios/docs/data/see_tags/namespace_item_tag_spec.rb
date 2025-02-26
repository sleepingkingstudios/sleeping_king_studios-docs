# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/see_tags/namespace_item_tag'

require 'support/contracts/data/see_tag_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Docs::Data::SeeTags::NamespaceItemTag do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:see_tag) { described_class.new(native:, parent:) }

  include_context 'with fixture files', 'see_tags'

  let(:fixture) { 'constant.rb' }
  let(:parent)  { YARD::Registry.find { |obj| obj.title == 'Space' } }
  let(:native)  { parent.tags.find { |tag| tag.tag_name == 'see' } }

  include_contract 'should be a see tag object',
    expected_json: lambda {
      {
        'label' => 'GRAVITY',
        'path'  => nil,
        'text'  => nil,
        'type'  => 'reference'
      }
    }

  describe '#local?' do
    include_examples 'should define predicate', :local?, false
  end

  describe '#path' do
    include_examples 'should define reader', :path, nil
  end

  describe '#type' do
    include_examples 'should define reader', :type, 'reference'
  end
end
