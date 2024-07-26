# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/see_tags/base'

require 'support/contracts/data/see_tag_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::SeeTags::Base do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:see_tag) { described_class.new(native:, parent:) }

  include_context 'with fixture files', 'see_tags'

  let(:fixture) { 'plain_text.rb' }
  let(:parent)  { YARD::Registry.find { |obj| obj.title == 'Space' } }
  let(:native)  { parent.tags.find { |tag| tag.tag_name == 'see' } }

  include_contract 'should be a see tag object', expected_json: -> { {} }

  describe '#text' do
    let(:expected) { 'This is a plain text message.' }

    include_examples 'should define reader', :text, -> { expected }

    wrap_context 'using fixture', 'empty' do
      it { expect(see_tag.text).to be nil }
    end
  end

  describe '#text?' do
    include_examples 'should define predicate', :text?, true

    wrap_context 'using fixture', 'empty' do
      it { expect(see_tag.text?).to be false }
    end
  end
end
