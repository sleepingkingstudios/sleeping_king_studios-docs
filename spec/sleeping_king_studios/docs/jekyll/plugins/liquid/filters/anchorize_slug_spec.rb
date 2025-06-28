# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/plugins/liquid/filters/anchorize_slug' # rubocop:disable Layout/LineLength

RSpec.describe SleepingKingStudios::Docs::Jekyll::Plugins::Liquid::Filters::AnchorizeSlug do # rubocop:disable Layout/LineLength
  subject(:filters) { Object.new.extend(described_class) }

  describe '#anchorize_slug' do
    it { expect(filters).to respond_to(:anchorize_slug).with(1).argument }

    describe 'with nil' do
      it { expect(filters.anchorize_slug(nil)).to be == '' }
    end

    describe 'with an Object' do
      let(:slug) { Object.new.freeze }

      it { expect(filters.anchorize_slug(slug)).to be == slug.to_s }
    end

    describe 'with an empty String' do
      it { expect(filters.anchorize_slug('')).to be == '' }
    end

    describe 'with a reference String' do
      let(:slug) { 'launch-rocket' }

      it { expect(filters.anchorize_slug(slug)).to be == slug }
    end

    describe 'with a reference String containing "="' do
      let(:slug)     { 'launch-site=' }
      let(:expected) { 'launch-site--equals' }

      it { expect(filters.anchorize_slug(slug)).to be == expected }
    end

    describe 'with a reference String containing "?"' do
      let(:slug)     { 'launched?' }
      let(:expected) { 'launched--predicate' }

      it { expect(filters.anchorize_slug(slug)).to be == expected }
    end

    describe 'with a reference String containing "[]"' do
      let(:slug)     { '[]' }
      let(:expected) { '--brackets' }

      it { expect(filters.anchorize_slug(slug)).to be == expected }
    end

    describe 'with a reference String containing multiple matched elements' do
      let(:slug)     { '[]=' }
      let(:expected) { '--brackets--equals' }

      it { expect(filters.anchorize_slug(slug)).to be == expected }
    end
  end
end
