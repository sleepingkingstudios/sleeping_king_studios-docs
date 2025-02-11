# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/installation/install_jekyll'

RSpec.describe \
  SleepingKingStudios::Yard::Commands::Installation::InstallJekyll \
do
  subject(:command) { described_class.new(**options) }

  let(:error_stream)  { StringIO.new }
  let(:output_stream) { StringIO.new }
  let(:options)       { { error_stream:, output_stream: } }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  describe '#call' do
    let(:docs_path) { '/path/to/docs' }
    let(:templates_command_class) do
      SleepingKingStudios::Yard::Commands::Installation::InstallTemplates
    end
    let(:mock_templates_command) do
      instance_double(templates_command_class, call: Cuprum::Result.new)
    end
    let(:gitignore_path) do
      File.join(Dir.pwd, '.gitignore')
    end
    let(:gitignore_contents) do
      <<~RAW
        #{docs_path}/.jekyll-cache
        #{docs_path}/_site
      RAW
    end
    let(:templates_path) do
      File.join(
        SleepingKingStudios::Yard.gem_path,
        'lib',
        'sleeping_king_studios',
        'yard',
        'templates'
      )
    end
    let(:config_template_path) do
      File.join(templates_path, 'config.yml.erb')
    end
    let(:jekyll_config_path) do
      File.join(docs_path, '_config.yml')
    end
    let(:expected_config) do
      <<~YAML
        ---
        collections:
          classes:
            output: false
          constants:
            output: false
          methods:
            output: false
          modules:
            output: false
          namespaces:
            output: false
        defaults:
        - scope:
            path: ''
            type: 'pages'
          values:
            encoding: 'utf-8'
            layout: 'default'
            title: '#{command.name}'
        description: |
          #{command.description}
      YAML
    end
    let(:index_template_path) do
      File.join(templates_path, 'pages', 'index.md.erb')
    end
    let(:index_page_path) do
      File.join(docs_path, 'index.md')
    end
    let(:expected_index_page) do
      <<~MARKDOWN
        ---
        breadcrumbs:
          - name: Documentation
            path: './'
        ---

        # #{command.name}

        #{command.description}

        ## Documentation

        This is the documentation for the [current development build](#{command.repository}) of #{command.name}.

        <!-- - For the most recent release, see [Version 0.1]({{site.baseurl}}/versions/0.1). -->
        - For previous releases, see the [Versions]({{site.baseurl}}/versions) page.

        ## Reference

        For a full list of defined classes and objects, see [Reference](./reference).

        {% include breadcrumbs.md %}
      MARKDOWN
    end
    let(:reference_template_path) do
      File.join(templates_path, 'pages', 'reference.md.erb')
    end
    let(:reference_page_path) do
      File.join(docs_path, 'reference', 'index.md')
    end
    let(:expected_reference_page) do
      <<~MARKDOWN
        ---
        breadcrumbs:
          - name: Documentation
            path: '../'
        version: '*'
        ---

        {% assign root_namespace = site.namespaces | where: "version", page.version | first %}

        # #{command.name} Reference

        {% include reference/namespace.md label=false namespace=root_namespace %}

        {% include breadcrumbs.md %}
      MARKDOWN
    end
    let(:versions_template_path) do
      File.join(templates_path, 'pages', 'versions.md.erb')
    end
    let(:versions_page_path) do
      File.join(docs_path, 'versions', 'index.md')
    end
    let(:expected_versions_page) do
      <<~MARKDOWN
        ---
        breadcrumbs:
          - name: Documentation
            path: '../'
        ---

        # Versions

        For more information on release versions, see the [Changelog](#{command.repository}/blob/main/CHANGELOG.md).

        <!-- - [Version 0.1]({{site.baseurl}}/versions/0.1) -->

        {% include breadcrumbs.md %}
      MARKDOWN
    end
    let(:breadcrumbs_template_path) do
      File.join(templates_path, 'includes', 'breadcrumbs.md')
    end
    let(:breadcrumbs_page_path) do
      File.join(docs_path, '_includes', 'breadcrumbs.md')
    end
    let(:expected_breadcrumbs) do
      <<~MARKDOWN

        ---

        Back to
        {% for breadcrumb in page.breadcrumbs -%}
        [{{ breadcrumb.name }}]({{breadcrumb.path}}){% unless forloop.last %} | {% endunless %}
        {% endfor %}
      MARKDOWN
    end
    let(:expected_output) do
      <<~OUTPUT
        Installing SleepingKingStudios::YARD to #{docs_path}...
          - Updating .gitignore
          - Creating Jekyll directory at #{docs_path}
          - Generating Jekyll configuration
          - Generating index page
          - Generating reference page
          - Generating versions page
          - Installing Jekyll templates
        Done!
      OUTPUT
    end

    before(:example) do
      allow(templates_command_class)
        .to receive(:new)
        .and_return(mock_templates_command)

      allow(Dir).to receive(:exist?).and_return(false)
      allow(File).to receive_messages(
        exist?: false,
        read:   '',
        write:  nil
      )
      allow(FileUtils).to receive_messages(
        mkdir_p: nil,
        touch:   nil
      )

      allow(File).to receive(:read).with(config_template_path).and_call_original
      allow(File).to receive(:read).with(index_template_path).and_call_original
      allow(File)
        .to receive(:read)
        .with(reference_template_path)
        .and_call_original
      allow(File)
        .to receive(:read)
        .with(versions_template_path)
        .and_call_original
      allow(File)
        .to receive(:read)
        .with(breadcrumbs_template_path)
        .and_call_original
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:docs_path, :project_path)
    end

    it 'should return a passing result' do
      expect(command.call(docs_path:))
        .to be_a_passing_result
        .with_value(nil)
    end

    it 'should update the gitignore file' do
      command.call(docs_path:)

      expect(File)
        .to have_received(:write)
        .with(gitignore_path, gitignore_contents)
    end

    it 'should create the docs directory' do
      command.call(docs_path:)

      expect(FileUtils)
        .to have_received(:mkdir_p)
        .with(docs_path)
    end

    it 'should create the Jekyll configuration' do
      command.call(docs_path:)

      expect(File)
        .to have_received(:write)
        .with(jekyll_config_path, expected_config)
    end

    it 'should generate the index page' do
      command.call(docs_path:)

      expect(File)
        .to have_received(:write)
        .with(index_page_path, expected_index_page)
    end

    it 'should create the reference directory' do
      command.call(docs_path:)

      expect(FileUtils)
        .to have_received(:mkdir_p)
        .with(File.join(docs_path, 'reference'))
    end

    it 'should generate the reference page' do
      command.call(docs_path:)

      expect(File)
        .to have_received(:write)
        .with(reference_page_path, expected_reference_page)
    end

    it 'should create the versions directory' do
      command.call(docs_path:)

      expect(FileUtils)
        .to have_received(:mkdir_p)
        .with(File.join(docs_path, 'versions'))
    end

    it 'should generate the versions page' do
      command.call(docs_path:)

      expect(File)
        .to have_received(:write)
        .with(versions_page_path, expected_versions_page)
    end

    it 'should generate the breadcrumbs template' do
      command.call(docs_path:)

      expect(File)
        .to have_received(:write)
        .with(breadcrumbs_page_path, expected_breadcrumbs)
    end

    it 'should generate the reference templates', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      command.call(docs_path:)

      expect(templates_command_class)
        .to have_received(:new)
        .with(
          dry_run:         false,
          force:           false,
          ignore_existing: true,
          verbose:         false
        )
      expect(mock_templates_command).to have_received(:call).with(docs_path:)
    end

    it 'should print the report to STDOUT' do
      command.call(docs_path:)

      expect(output_stream.string).to be == expected_output
    end

    it 'should not print to STDERR' do
      command.call(docs_path:)

      expect(error_stream.string).to be == ''
    end

    describe 'with docs_path: a path starting with "."' do
      let(:docs_path) { './docs' }
      let(:gitignore_contents) do
        <<~RAW
          #{docs_path.sub(/\A\./, '')}/.jekyll-cache
          #{docs_path.sub(/\A\./, '')}/_site
        RAW
      end

      it 'should update the gitignore file' do
        command.call(docs_path:)

        expect(File)
          .to have_received(:write)
          .with(gitignore_path, gitignore_contents)
      end

      context 'when the gitignore file includes the jekyll cache' do
        let(:existing_gitignore) do
          "#{docs_path.sub(/\A\./, '')}/.jekyll-cache\n"
        end

        before(:example) do
          allow(File)
            .to receive(:read)
            .with(gitignore_path)
            .and_return(existing_gitignore)
        end

        it 'should update the gitignore file' do
          command.call(docs_path:)

          expect(File)
            .to have_received(:write)
            .with(gitignore_path, gitignore_contents)
        end
      end

      context 'when the gitignore file includes the jekyll site' do
        let(:existing_gitignore) do
          "#{docs_path.sub(/\A\./, '')}/_site\n"
        end
        let(:gitignore_contents) do
          <<~RAW
            #{docs_path.sub(/\A\./, '')}/_site
            #{docs_path.sub(/\A\./, '')}/.jekyll-cache
          RAW
        end

        before(:example) do
          allow(File)
            .to receive(:read)
            .with(gitignore_path)
            .and_return(existing_gitignore)
        end

        it 'should update the gitignore file' do
          command.call(docs_path:)

          expect(File)
            .to have_received(:write)
            .with(gitignore_path, gitignore_contents)
        end
      end
    end

    describe 'with project_path: value' do
      let(:project_path) { '/path/to/root' }
      let(:gitignore_path) do
        File.join(project_path, '.gitignore')
      end

      it 'should update the gitignore file' do
        command.call(docs_path:, project_path:)

        expect(File)
          .to have_received(:write)
          .with(gitignore_path, gitignore_contents)
      end
    end

    context 'when the gitignore file includes the jekyll cache' do
      let(:existing_gitignore) do
        "#{docs_path}/.jekyll-cache\n"
      end

      before(:example) do
        allow(File)
          .to receive(:read)
          .with(gitignore_path)
          .and_return(existing_gitignore)
      end

      it 'should update the gitignore file' do
        command.call(docs_path:)

        expect(File)
          .to have_received(:write)
          .with(gitignore_path, gitignore_contents)
      end
    end

    context 'when the gitignore file includes the jekyll site' do
      let(:existing_gitignore) do
        "#{docs_path}/_site\n"
      end
      let(:gitignore_contents) do
        <<~RAW
          #{docs_path}/_site
          #{docs_path}/.jekyll-cache
        RAW
      end

      before(:example) do
        allow(File)
          .to receive(:read)
          .with(gitignore_path)
          .and_return(existing_gitignore)
      end

      it 'should update the gitignore file' do
        command.call(docs_path:)

        expect(File)
          .to have_received(:write)
          .with(gitignore_path, gitignore_contents)
      end
    end

    context 'when the docs directory already exists' do
      before(:example) do
        allow(Dir).to receive(:exist?).with(docs_path).and_return(true)
      end

      it 'should not create the docs directorie' do
        command.call(docs_path:)

        expect(FileUtils).not_to have_received(:mkdir_p).with(docs_path)
      end
    end

    context 'when the Jekyll configuration already exists' do
      before(:example) do
        allow(File)
          .to receive(:exist?)
          .with(jekyll_config_path)
          .and_return(true)
      end

      it 'should not create the Jekyll configuration' do
        command.call(docs_path:)

        expect(File)
          .not_to have_received(:write)
          .with(jekyll_config_path, an_instance_of(String))
      end
    end

    context 'when the index page already exists' do
      before(:example) do
        allow(File)
          .to receive(:exist?)
          .with(index_page_path)
          .and_return(true)
      end

      it 'should not create the index page' do
        command.call(docs_path:)

        expect(File)
          .not_to have_received(:write)
          .with(index_page_path, an_instance_of(String))
      end
    end

    context 'when the reference page already exists' do
      before(:example) do
        allow(File)
          .to receive(:exist?)
          .with(reference_page_path)
          .and_return(true)
      end

      it 'should not create the reference page' do
        command.call(docs_path:)

        expect(File)
          .not_to have_received(:write)
          .with(reference_page_path, an_instance_of(String))
      end
    end

    context 'when the versions page already exists' do
      before(:example) do
        allow(File)
          .to receive(:exist?)
          .with(versions_page_path)
          .and_return(true)
      end

      it 'should not create the reference page' do
        command.call(docs_path:)

        expect(File)
          .not_to have_received(:write)
          .with(versions_page_path, an_instance_of(String))
      end
    end

    context 'when the breadcrumbs page already exists' do
      before(:example) do
        allow(File)
          .to receive(:exist?)
          .with(breadcrumbs_page_path)
          .and_return(true)
      end

      it 'should not create the reference page' do
        command.call(docs_path:)

        expect(File)
          .not_to have_received(:write)
          .with(breadcrumbs_page_path, an_instance_of(String))
      end
    end

    context 'when initialized with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it 'should not create any directories' do
        command.call(docs_path:)

        expect(FileUtils).not_to have_received(:mkdir_p)
      end

      it 'should not write any files' do
        command.call(docs_path:)

        expect(File).not_to have_received(:write)
      end

      it 'should not generate the reference templates', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        command.call(docs_path:)

        expect(templates_command_class)
          .to have_received(:new)
          .with(
            dry_run:         true,
            force:           false,
            ignore_existing: true,
            verbose:         false
          )
        expect(mock_templates_command).to have_received(:call).with(docs_path:)
      end

      it 'should print the report to STDOUT' do
        command.call(docs_path:)

        expect(output_stream.string).to be == expected_output
      end
    end

    context 'when initialized with verbose: false' do
      let(:options) { super().merge(verbose: false) }

      it 'should not print to STDOUT' do
        command.call(docs_path:)

        expect(output_stream.string).to be == ''
      end

      it 'should not print to STDERR' do
        command.call(docs_path:)

        expect(error_stream.string).to be == ''
      end
    end
  end

  describe '#description' do
    include_examples 'should define reader', :description, 'A Ruby library.'

    context 'when initialized with description: value' do
      let(:options) { super().merge(description: 'A real gem.') }

      it { expect(command.description).to be == 'A real gem.' }
    end
  end

  describe '#dry_run?' do
    include_examples 'should define predicate', :dry_run?, false

    context 'when initialized with dry_run: false' do
      let(:options) { super().merge(dry_run: false) }

      it { expect(command.dry_run?).to be false }
    end

    context 'when initialized with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it { expect(command.dry_run?).to be true }
    end
  end

  describe '#name' do
    include_examples 'should define reader', :name, 'Library Name'

    context 'when initialized with name: value' do
      let(:options) { super().merge(name: 'Orichalcum') }

      it { expect(command.name).to be == 'Orichalcum' }
    end
  end

  describe '#repository' do
    include_examples 'should define reader', :repository, 'www.example.com'

    context 'when initialized with repository: value' do
      let(:options) { super().merge(repository: 'www.example.com/orichalcum') }

      it { expect(command.repository).to be == 'www.example.com/orichalcum' }
    end
  end

  describe '#verbose?' do
    include_examples 'should define predicate', :verbose?, true

    context 'when initialized with verbose: false' do
      let(:options) { super().merge(verbose: false) }

      it { expect(command.verbose?).to be false }
    end

    context 'when initialized with verbose: true' do
      let(:options) { super().merge(verbose: true) }

      it { expect(command.verbose?).to be true }
    end
  end
end
