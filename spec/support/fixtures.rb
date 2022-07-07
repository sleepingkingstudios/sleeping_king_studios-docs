# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Support
  module Fixtures
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'using fixture' do |fixture_name, **options| # rubocop:disable RSpec/ContextWording
      let(:fixture) { "#{fixture_name.tr ' ', '_'}.rb" }

      # :nocov:
      options.each do |option, value|
        let(option) { value }
      end
      # :nocov:
    end

    shared_context 'with fixture files' do |directory|
      around(:example) do |example|
        filename = File.join('spec/fixtures', directory, fixture)

        raise "Fixture not found at #{filename}" unless File.exist?(filename)

        ::YARD.parse(filename)

        example.call
      ensure
        ::YARD::Registry.clear
      end
    end
  end
end
