# frozen_string_literal: true

require 'cuprum/command'
require 'sleeping_king_studios/tools/toolbelt'

require 'sleeping_king_studios/yard/commands'

module SleepingKingStudios::Yard::Commands
  # Generates YARD documentation files.
  class Generate < SleepingKingStudios::Yard::Commands::Generators::Base # rubocop:disable Metrics/ClassLength
    private

    def data_commands # rubocop:disable Metrics/MethodLength
      @data_commands ||= Hash.new do |hsh, data_type|
        class_name = "#{tools.string_tools.camelize(data_type.to_s)}Object"
        data_class = SleepingKingStudios::Yard::Data.const_get(class_name)

        hsh[data_type] =
          SleepingKingStudios::Yard::Commands::Generators::DataGenerator
          .new(
            data_class: data_class,
            data_type:  data_type,
            docs_path:  docs_path,
            **options
          )
      end
    end

    def generate_classes
      puts "\nGenerating Classes:" if verbose? && !registry_classes.empty?

      registry_classes.each do |native|
        data_commands[:class].call(native: native)
        reference_commands[:class].call(native: native)
      end
    end

    def generate_constants
      puts "\nGenerating Constants:" if verbose? && !registry_constants.empty?

      registry_constants.each do |native|
        data_commands[:constant].call(native: native)
      end
    end

    def generate_methods
      puts "\nGenerating Methods:" if verbose? && !registry_methods.empty?

      registry_methods.each do |native|
        data_commands[:method].call(native: native)
      end
    end

    def generate_modules
      puts "\nGenerating Modules:" if verbose? && !registry_modules.empty?

      registry_modules.each do |native|
        data_commands[:module].call(native: native)
        reference_commands[:module].call(native: native)
      end
    end

    def generate_root_namespace
      puts 'Generating Root Namespace:' if verbose?

      namespace_command.call(native: registry_root)
    end

    def namespace_command
      @namespace_command ||=
        SleepingKingStudios::Yard::Commands::Generators::DataGenerator
        .new(
          data_class: SleepingKingStudios::Yard::Data::RootObject,
          data_type:  :namespace,
          docs_path:  docs_path,
          **options
        )
    end

    def parse_registry(file_path:)
      SleepingKingStudios::Yard::Commands::Parse.new.call(file_path)
    end

    def process(file_path: nil)
      step { parse_registry(file_path: file_path) }

      generate_root_namespace
      generate_classes
      generate_constants
      generate_methods
      generate_modules

      nil
    end

    def reference_commands # rubocop:disable Metrics/MethodLength
      @reference_commands ||= Hash.new do |hsh, reference_type|
        class_name      =
          "#{tools.string_tools.camelize(reference_type.to_s)}Object"
        reference_class =
          SleepingKingStudios::Yard::Data.const_get(class_name)

        hsh[reference_type] =
          SleepingKingStudios::Yard::Commands::Generators::ReferenceGenerator
          .new(
            docs_path:       docs_path,
            reference_class: reference_class,
            reference_type:  reference_type,
            **options
          )
      end
    end

    def registry
      SleepingKingStudios::Yard::Registry.instance
    end

    def registry_classes
      registry
        .select { |obj| obj.type == :class }
        .sort_by(&:path)
    end

    def registry_constants
      registry
        .select { |obj| obj.type == :constant }
        .sort_by(&:path)
    end

    def registry_methods
      registry
        .select { |obj| obj.type == :method && obj.visibility == :public }
        .sort_by(&:path)
    end

    def registry_modules
      registry
        .select { |obj| obj.type == :module }
        .sort_by(&:path)
    end

    def registry_root
      registry
        .find { |obj| obj.type == :root }
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
