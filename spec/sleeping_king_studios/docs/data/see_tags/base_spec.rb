# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/see_tags/base'

require 'support/deferred/data_examples'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Docs::Data::SeeTags::Base do
  include Spec::Support::Deferred::DataExamples
  include Spec::Support::Fixtures

  subject(:see_tag) { described_class.new(native:, parent:) }

  include_context 'with fixture files', 'see_tags'

  let(:fixture) { 'plain_text.rb' }
  let(:parent)  { YARD::Registry.find { |obj| obj.title == 'Space' } }
  let(:native)  { parent.tags.find { |tag| tag.tag_name == 'see' } }

  include_deferred 'should be a @see tag object'

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
