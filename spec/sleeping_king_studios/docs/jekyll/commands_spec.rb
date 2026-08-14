# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll/commands'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Commands do
  describe '.templates_path' do
    let(:expected) do
      File.join(
        SleepingKingStudios::Docs.gem_path,
        'lib',
        'sleeping_king_studios',
        'docs',
        'templates'
      )
    end

    include_examples 'should define class reader',
      :templates_path,
      -> { expected }
  end
end
