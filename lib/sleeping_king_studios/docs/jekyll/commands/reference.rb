# frozen_string_literal: true

require 'cuprum/cli'

require 'sleeping_king_studios/docs/jekyll/commands'

module SleepingKingStudios::Docs::Jekyll::Commands
  # Abstract base class for commands that update the reference documentation.
  class Reference < Cuprum::Cli::Command
    dependency :file_system
    dependency :standard_io

    include Cuprum::Cli::Dependencies::StandardIo::Helpers
    include Cuprum::Cli::Options::Quiet
    include Cuprum::Cli::Options::Verbose

    option :docs_path, default: 'docs'

    option :version

    # @return [String] the directory for defining class data YAML files.
    def class_data_directory
      @class_data_directory ||=
        if version
          File.join(docs_path, '_classes', "version--#{version}")
        else
          File.join(docs_path, '_classes')
        end
    end

    # @return [String] the directory for defining constant data YAML files.
    def constant_data_directory
      @constant_data_directory ||=
        if version
          File.join(docs_path, '_constants', "version--#{version}")
        else
          File.join(docs_path, '_constants')
        end
    end

    # @return [String] the directory for defining method data YAML files.
    def method_data_directory
      @method_data_directory ||=
        if version
          File.join(docs_path, '_methods', "version--#{version}")
        else
          File.join(docs_path, '_methods')
        end
    end

    # @return [String] the directory for defining module data YAML files.
    def module_data_directory
      @module_data_directory ||=
        if version
          File.join(docs_path, '_modules', "version--#{version}")
        else
          File.join(docs_path, '_modules')
        end
    end

    # @return [String] the directory for defining namespace data YAML files.
    def namespace_data_directory
      @namespace_data_directory ||=
        if version
          File.join(docs_path, '_namespaces', "version--#{version}")
        else
          File.join(docs_path, '_namespaces')
        end
    end

    # @return [String] the directory for defining reference Markdown files.
    def reference_directory
      @reference_directory ||=
        if version
          File.join(docs_path, 'versions', version, 'reference')
        else
          File.join(docs_path, 'reference')
        end
    end
  end
end
