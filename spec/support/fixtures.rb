# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'sleeping_king_studios/tools/toolbox/mixin'

module Spec::Support
  module Fixtures
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    module ClassMethods
      def wrap_context(context_name, *args, **kwargs, &block)
        return super unless context_name == 'using fixture'

        context %(using fixture "#{args.first}") do # rubocop:disable RSpec/ContextWording
          include_context 'using fixture', *args, **kwargs

          instance_exec(&block)
        end
      end
    end

    shared_context 'using fixture' do |fixture_name, **options| # rubocop:disable RSpec/ContextWording
      let(:fixture) { "#{fixture_name.tr ' ', '_'}.rb" }

      # :nocov:
      options.each do |option, value|
        let(option) { value }
      end
      # :nocov:
    end

    shared_context 'with fixture files' do |directory|
      let(:fixture_directory) { directory }

      around(:example) do |example|
        filename = File.join('spec/fixtures', fixture_directory, fixture)

        raise "Fixture not found at #{filename}" unless File.exist?(filename)

        ::YARD.parse(filename)

        example.call
      ensure
        ::YARD::Registry.clear

        SleepingKingStudios::Yard::Registry.clear
      end
    end
  end
end
