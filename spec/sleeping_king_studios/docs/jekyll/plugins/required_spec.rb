# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/plugins/required'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Plugins::Required do
  let(:plugins) { SleepingKingStudios::Docs::Jekyll::Plugins }

  it 'should require the AnchorizeSlug plugin' do
    expect(described_class.ancestors)
      .to include plugins::Liquid::Filters::AnchorizeSlug
  end
end
