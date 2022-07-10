# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/base'

require 'support/contracts/data/base_contract'
require 'support/fixtures'

RSpec.describe SleepingKingStudios::Yard::Data::Base do
  include Spec::Support::Contracts::Data
  include Spec::Support::Fixtures

  subject(:constant_object) do
    described_class.new(native: native, registry: registry)
  end

  include_context 'with fixture files', 'modules'

  let(:fixture)  { 'basic.rb' }
  let(:registry) { ::YARD::Registry }
  let(:native)   { registry.root }

  include_contract 'should be a data object'
end
