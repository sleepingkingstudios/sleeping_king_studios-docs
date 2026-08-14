# frozen_string_literal: true

require 'cuprum/cli/rspec/deferred/generators_examples'
require 'cuprum/cli/rspec/deferred/options_examples'

require 'sleeping_king_studios/docs/jekyll/commands/install'

RSpec.describe SleepingKingStudios::Docs::Jekyll::Commands::Install do
  include Cuprum::Cli::RSpec::Deferred::OptionsExamples

  subject(:command) { described_class.new(file_system:, standard_io:) }

  let(:templates_path) do
    SleepingKingStudios::Docs::Jekyll::Commands.templates_path
  end
  let(:template_files) do
    config_template = <<~YAML
      ---
      name: '<%= project_name %>'
      description: '<%= project_description %>'
      repository: '<%= project_repository %>'
    YAML

    {
      'config.yml.erb'              => config_template,
      'deploy-pages.yml.erb'        => "name: Deploy Jekyll site to Pages\n",
      'includes/template.md'        => 'Top Level Template',
      'includes/reference/inner.md' => 'Reference Template',
      'layouts/page.html.erb'       => "# Page\n{{ content }}",
      'pages/index.md.erb'          => "# Index Page\n",
      'pages/reference.md.erb'      => "# Reference Page\n",
      'pages/versions.md.erb'       => "# Versions Page\n"
    }
      .transform_keys { |path| File.join(templates_path, path) }
  end
  let(:files) do
    tools.hash_tools.deep_dup(template_files)
  end
  let(:file_system) do
    Cuprum::Cli::Dependencies::FileSystem::Mock.new(files:)
  end
  let(:standard_io) do
    Cuprum::Cli::Dependencies::StandardIo::Mock.new
  end

  describe '::Generator' do
    include Cuprum::Cli::RSpec::Deferred::GeneratorsExamples

    subject(:generator) do
      described_class.new(
        file_system:,
        standard_io:,
        **options
      )
    end

    let(:described_class) { super()::Generator }
    let(:docs_path)       { '' }
    let(:options)         { {} }

    include_deferred 'should define option',
      :docs_path,
      default: 'docs',
      type:    :string

    include_deferred 'should define option',
      :project_description,
      default: '',
      type:    :string

    include_deferred 'should define option',
      :project_name,
      default: 'Project Name',
      type:    :string

    include_deferred 'should define option',
      :project_repository,
      default: '',
      type:    :string

    include_deferred 'should output file',
      '%<docs_path>s/_config.yml',
      key:      :config,
      template: -> { File.join(templates_path, 'config.yml.erb') }

    include_deferred 'should output file',
      '%<docs_path>s/_layouts/page.html',
      key:      :layout,
      template: -> { File.join(templates_path, 'layouts', 'page.html.erb') }

    include_deferred 'should output file',
      '%<docs_path>s/index.md',
      key:      :index,
      template: -> { File.join(templates_path, 'pages', 'index.md.erb') }

    include_deferred 'should output file',
      '%<docs_path>s/reference/index.md',
      key:      :reference,
      template: -> { File.join(templates_path, 'pages', 'reference.md.erb') }

    include_deferred 'should output file',
      '%<docs_path>s/versions/index.md',
      key:      :versions,
      template: -> { File.join(templates_path, 'pages', 'versions.md.erb') }
  end

  include_deferred 'should define option',
    :docs_path,
    type:    :string,
    default: 'docs'

  include_deferred 'should define option',
    :dry_run,
    type:    :boolean,
    default: false

  include_deferred 'should define option',
    :force,
    type:    :boolean,
    default: false

  include_deferred 'should define option',
    :gemfile,
    type:    :boolean,
    default: true

  include_deferred 'should define option',
    :gitignore,
    type:    :boolean,
    default: true

  include_deferred 'should define option',
    :templates,
    type:    :boolean,
    default: true

  include_deferred 'should define option',
    :workflow,
    type:    :boolean,
    default: false

  include_deferred 'should define --quiet option'

  include_deferred 'should define --verbose option'

  describe '#call' do
    deferred_examples 'should generate the expected files' do |workflow: false|
      it 'should generate the docs directory' do
        call_command

        expect(file_system.directory?(command.docs_path)).to be true
      end

      it 'should generate the expected files', :aggregate_failures do
        call_command

        expected_files.each do |file_path, contents|
          expect(file_system.file?(file_path)).to be true
          expect(file_system.read_file(file_path)).to eq(contents)
        end
      end

      unless workflow
        it 'should not install the workflow' do
          call_command

          expect(file_system.file?('.github/workflows/deploy-pages.yml'))
            .to be false
        end
      end
    end

    deferred_examples 'should output to STDOUT' do
      it 'should output to STDOUT' do
        call_command

        expect(standard_io.output_stream.string).to eq(expected_output)
      end

      it 'should not output to STDERR' do
        call_command

        expect(standard_io.error_stream.string).to eq('')
      end

      context 'when initialized with quiet: true' do
        let(:options) { super().merge(quiet: true) }

        it 'should not output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq('')
        end

        it 'should not output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq('')
        end
      end

      context 'when initialized with verbose: true' do
        let(:options) { super().merge(verbose: true) }
        let(:expected_output) do
          expected_outputs
            .map do |key, value|
              next "#{key}\n\n" if value.empty?

              "#{key}\n\n#{tools.string_tools.indent(value.strip, 2)}\n\n"
            end
            .join
        end

        it 'should output to STDOUT' do
          call_command

          expect(standard_io.output_stream.string).to eq(expected_output)
        end

        it 'should not output to STDERR' do
          call_command

          expect(standard_io.error_stream.string).to eq('')
        end
      end
    end

    deferred_examples 'should install the Jekyll application' do
      include_deferred 'should generate the expected files'

      include_deferred 'should output to STDOUT'

      describe 'with docs_path: value' do
        let(:docs_path) { 'path/to/docs' }
        let(:options)   { super().merge(docs_path:) }

        include_deferred 'should generate the expected files'

        include_deferred 'should output to STDOUT'
      end

      describe 'with dry_run: true' do
        let(:options) { super().merge(dry_run: true) }

        it 'should not update the file system' do
          expect { call_command }.not_to change(file_system, :files)
        end
      end

      describe 'with gemfile: false' do
        let(:options) { super().merge(gemfile: false) }
        let(:expected_files) do
          super().except('Gemfile')
        end

        include_deferred 'should generate the expected files'

        include_deferred 'should output to STDOUT'

        it 'should not update the Gemfile', :aggregate_failures do
          existing = file_system.file?('Gemfile')
          contents = file_system.read_file('Gemfile') if existing

          call_command

          expect(file_system.file?('Gemfile')).to be existing
          expect(file_system.read_file('Gemfile')).to eq contents if existing
        end
      end

      describe 'with gitignore: false' do
        let(:options) { super().merge(gitignore: false) }
        let(:expected_files) do
          super().except('.gitignore')
        end

        include_deferred 'should generate the expected files'

        include_deferred 'should output to STDOUT'

        it 'should not update the .gitignore', :aggregate_failures do
          existing = file_system.file?('.gitignore')
          contents = file_system.read_file('.gitignore') if existing

          call_command

          expect(file_system.file?('.gitignore')).to be existing
          expect(file_system.read_file('.gitignore')).to eq contents if existing
        end
      end

      describe 'with templates: false' do
        let(:options) { super().merge(templates: false) }
        let(:expected_files) do
          super().except(*expected_templates.keys)
        end

        include_deferred 'should generate the expected files'

        include_deferred 'should output to STDOUT'

        it 'should not generate the template files', :aggregate_failures do
          call_command

          expected_templates.each_key do |file_path|
            expect(file_system.file?(file_path)).to be false
          end
        end
      end

      describe 'with workflow: true' do
        let(:options) { super().merge(workflow: true) }
        let(:expected_workflow) do
          "name: Deploy Jekyll site to Pages\n"
        end
        let(:expected_files) do
          super().merge(
            '.github/workflows/deploy-pages.yml' => expected_workflow
          )
        end

        include_deferred 'should generate the expected files', workflow: true

        include_deferred 'should output to STDOUT'
      end
    end

    let(:options) { {} }
    let(:expected_gemfile) do
      <<~GEMFILE
        # frozen_string_literal: true

        source 'https://rubygems.org'

        group: :docs do
          gem 'jekyll', '~> 4.4'
          gem 'kramdown-parser-gfm', '~> 1.1'
          gem 'webrick', '~> 1.8'
        end
      GEMFILE
    end
    let(:expected_gitignore) do
      <<~GITIGNORE
        # Ignore Jekyll site and temporary files.
        #{command.docs_path}/_site
        #{command.docs_path}/.sass-cache
        #{command.docs_path}/.jekyll-cache
        #{command.docs_path}/.jekyll-metadata
        vendor
      GITIGNORE
    end
    let(:expected_templates) do
      docs_path = defined?(self.docs_path) ? self.docs_path : 'docs'

      {
        "#{docs_path}/_includes/template.md"        => 'Top Level Template',
        "#{docs_path}/_includes/reference/inner.md" => 'Reference Template'
      }
    end
    let(:expected_static_files) do
      docs_path  = defined?(self.docs_path) ? self.docs_path : 'docs'
      options    = {
        docs_path:           'docs',
        project_description: '',
        project_name:        'Project Name',
        project_repository:  ''
      }.merge(self.options)
      file_paths = {
        '_config.yml'        => 'config.yml.erb',
        '_layouts/page.html' => 'layouts/page.html.erb',
        'index.md'           => 'pages/index.md.erb',
        'reference/index.md' => 'pages/reference.md.erb',
        'versions/index.md'  => 'pages/versions.md.erb'
      }

      file_paths
        .transform_keys { |path| File.join(docs_path, path) }
        .transform_values do |path|
          template = file_system.read_file(File.join(templates_path, path))
          result   =
            Cuprum::Cli::Files::Engines::RenderErb.new.call(template, **options)

          raise result.error.message unless result.success?

          result.value
        end
    end
    let(:expected_files) do
      expected_static_files
        .merge(expected_templates)
        .merge(
          '.gitignore' => expected_gitignore,
          'Gemfile'    => expected_gemfile
        )
    end
    let(:expected_keys) do
      expected_files.each_key.map do |file_path|
        # :nocov:
        next file_path unless file_path.start_with?(file_system.root_path)

        file_path[(file_system.root_path.size + 1)...]
        # :nocov:
      end
    end
    let(:expected_outputs) do
      docs_path  = defined?(self.docs_path) ? self.docs_path : 'docs'
      expected   = {}

      if options.fetch(:gitignore, true)
        expected['Generating .gitignore...'] = expected_gitignore
      end

      if options.fetch(:gemfile, true)
        expected['Generating Gemfile...'] = expected_gemfile
      end

      expected["Generating directory #{docs_path}..."] = ''

      expected_static_files.each do |file_path, contents|
        expected["Generating file #{file_path}..."] = contents
      end

      if options.fetch(:templates, true)
        templates_report =
          expected_templates
          .each_key
          .map do |template_path|
            prefix        = "#{docs_path}/_includes"
            template_path = template_path[(prefix.size + 1)...]

            "- Copying template #{template_path}\n"
          end
          .join

        expected['Copying template files (force=false)...'] = templates_report
      end

      if options.fetch(:workflow, false)
        expected['Generating file .github/workflows/deploy-pages.yml...'] =
          expected_workflow
      end

      expected
    end
    let(:expected_output) do
      expected_outputs.each_key.map { |out| "#{out}\n" }.join
    end

    define_method :call_command do
      command.call(**options)
    end

    define_method :replace_key do |old_hsh, old_key, new_key, &block|
      new_hsh = {}

      old_hsh.each do |key, value|
        value = block.call(value) if block

        new_hsh[old_key == key ? new_key : key] = value
      end

      new_hsh
    end

    it 'should return a passing result' do
      expect(call_command)
        .to be_a_passing_result
        .with_value(match_array(expected_keys))
    end

    include_deferred 'should install the Jekyll application'

    context 'when the working directory already has a .gitignore file' do
      let(:existing_gitignore) do
        <<~GITIGNORE
          # Ignore temporary files.
          tmp
          vendor
        GITIGNORE
      end
      let(:expected_gitignore) do
        <<~GITIGNORE
          # Ignore temporary files.
          tmp
          vendor

          # Ignore Jekyll site and temporary files.
          #{command.docs_path}/_site
          #{command.docs_path}/.sass-cache
          #{command.docs_path}/.jekyll-cache
          #{command.docs_path}/.jekyll-metadata
        GITIGNORE
      end
      let(:expected_outputs) do
        replace_key(
          super(),
          'Generating .gitignore...',
          'Updating .gitignore...'
        )
      end

      before(:example) do
        file_system.write_file('.gitignore', existing_gitignore)
      end

      include_deferred 'should install the Jekyll application'

      context 'when the .gitignore ignores all paths' do
        let(:existing_gitignore) do
          docs_path = options.fetch(:docs_path, 'docs')

          <<~GITIGNORE
            # Jekyll
            #{docs_path}/_site
            #{docs_path}/.sass-cache
            #{docs_path}/.jekyll-cache
            #{docs_path}/.jekyll-metadata

            # Other
            tmp
            vendor
          GITIGNORE
        end
        let(:expected_files) { super().except('.gitignore') }
        let(:expected_outputs) do
          super().tap { |hsh| hsh.delete('Updating .gitignore...') }
        end

        include_deferred 'should install the Jekyll application'

        it 'should not update the .gitignore', :aggregate_failures do
          existing = file_system.file?('.gitignore')
          contents = file_system.read_file('.gitignore') if existing

          call_command

          expect(file_system.file?('.gitignore')).to be existing
          expect(file_system.read_file('.gitignore')).to eq contents if existing
        end
      end

      context 'when updating the .gitignore fails' do
        let(:error_message) { 'something went wrong' }
        let(:expected_error) do
          Cuprum::Cli::Files::Errors::FileNotWriteable.new(
            file_path: '.gitignore',
            message:   error_message
          )
        end

        before(:example) do
          allow(file_system).to receive(:write_file).and_call_original
          allow(file_system)
            .to receive(:write_file)
            .with('.gitignore', an_instance_of(String))
            .and_raise(
              Cuprum::Cli::Dependencies::FileSystem::FileError,
              error_message
            )
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    context 'when the working directory already has a Gemfile' do
      let(:existing_gemfile) do
        <<~GEMFILE
          # frozen_string_literal: true

          source 'https://rubygems.org'

          gemspec

          gem 'webrick'

          group :development, :test do
            gem 'cuprum-cli'
          end
        GEMFILE
      end
      let(:expected_gemfile) do
        <<~GEMFILE
          # frozen_string_literal: true

          source 'https://rubygems.org'

          gemspec

          gem 'webrick'

          group :development, :test do
            gem 'cuprum-cli'
          end

          group :docs do
            gem 'jekyll', '~> 4.4'
            gem 'kramdown-parser-gfm', '~> 1.1'
          end
        GEMFILE
      end
      let(:expected_files) { super().except('Gemfile') }
      let(:expected_outputs) do
        replace_key(
          super(),
          'Generating Gemfile...',
          'Updating Gemfile...'
        )
      end

      before(:example) do
        file_system.write_file('Gemfile', existing_gemfile)
      end

      include_deferred 'should install the Jekyll application'

      context 'when the Gemfile includes all gems' do
        let(:existing_gemfile) do
          <<~GEMFILE
            # frozen_string_literal: true

            source 'https://rubygems.org'

            gemspec

            group :documentation do
              gem 'jekyll'
              gem 'kramdown-parser-gfm'
              gem 'webrick'
            end

            group :development, :test do
              gem 'cuprum-cli'
            end
          GEMFILE
        end
        let(:expected_outputs) do
          super().tap { |hsh| hsh.delete('Updating Gemfile...') }
        end

        include_deferred 'should install the Jekyll application'

        it 'should not update the Gemfile', :aggregate_failures do
          existing = file_system.file?('Gemfile')
          contents = file_system.read_file('Gemfile') if existing

          call_command

          expect(file_system.file?('Gemfile')).to be existing
          expect(file_system.read_file('Gemfile')).to eq contents if existing
        end
      end

      context 'when updating the Gemfile fails' do
        let(:error_message) { 'something went wrong' }
        let(:expected_error) do
          Cuprum::Cli::Files::Errors::FileNotWriteable.new(
            file_path: 'Gemfile',
            message:   error_message
          )
        end

        before(:example) do
          allow(file_system).to receive(:write_file).and_call_original
          allow(file_system)
            .to receive(:write_file)
            .with('Gemfile', an_instance_of(String))
            .and_raise(
              Cuprum::Cli::Dependencies::FileSystem::FileError,
              error_message
            )
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    context 'when creating the .gitignore fails' do
      let(:error_message) { 'something went wrong' }
      let(:expected_error) do
        Cuprum::Cli::Files::Errors::FileNotWriteable.new(
          file_path: '.gitignore',
          message:   error_message
        )
      end

      before(:example) do
        allow(file_system).to receive(:write_file).and_call_original
        allow(file_system)
          .to receive(:write_file)
          .with('.gitignore', an_instance_of(String))
          .and_raise(
            Cuprum::Cli::Dependencies::FileSystem::FileError,
            error_message
          )
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when creating the Gemfile fails' do
      let(:error_message) { 'something went wrong' }
      let(:expected_error) do
        Cuprum::Cli::Files::Errors::FileNotWriteable.new(
          file_path: 'Gemfile',
          message:   error_message
        )
      end

      before(:example) do
        allow(file_system).to receive(:write_file).and_call_original
        allow(file_system)
          .to receive(:write_file)
          .with('Gemfile', an_instance_of(String))
          .and_raise(
            Cuprum::Cli::Dependencies::FileSystem::FileError,
            error_message
          )
      end

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end
end
