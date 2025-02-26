# frozen_string_literal: true

require 'sleeping_king_studios/docs/data/base'

require 'support/contracts/data/base_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Docs::Data::Base do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:constant_object) { described_class.new(native:) }

  include_context 'with fixture files', 'modules'

  let(:fixture) { 'basic.rb' }
  let(:native)  { YARD::Registry.root }

  include_contract 'should be a data object'
end
