# frozen_string_literal: true

require 'cuprum/cli/rspec/deferred/options_examples'

require 'sleeping_king_studios/docs/jekyll/commands/reference'

require 'support/deferred/reference_examples'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Commands::Reference do
  include Cuprum::Cli::RSpec::Deferred::OptionsExamples
  include Spec::Support::Deferred::ReferenceExamples

  subject(:command) { described_class.new }

  let(:options) { {} }

  include_deferred 'should define option',
    :docs_path,
    type:    :string,
    default: 'docs'

  include_deferred 'should define option',
    :version,
    type: :string

  include_deferred 'should implement the path helpers'
end
