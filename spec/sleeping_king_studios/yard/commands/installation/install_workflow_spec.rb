# frozen_string_literal: true

require 'sleeping_king_studios/yard/commands/installation/install_workflow'

RSpec.describe \
  SleepingKingStudios::Yard::Commands::Installation::InstallWorkflow \
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
    let(:root_path) { Dir.pwd }
    let(:templates_path) do
      File.join(
        SleepingKingStudios::Yard.gem_path,
        'lib',
        'sleeping_king_studios',
        'yard',
        'templates',
        'includes',
        'reference'
      )
    end
    let(:workflow_directory) do
      File.join(root_path, '.github', 'workflows')
    end
    let(:workflow_template_path) do
      File.join(templates_path, 'deploy-pages.yml.erb')
    end
    let(:workflow_file_path) do
      File.join(workflow_directory, 'deploy-pages.yml')
    end
    let(:expected_workflow) do
      ruby_version = RUBY_VERSION.split('.')[0..1].join('.')

      <<~YAML
        name: Deploy Jekyll site to Pages

        on:
          push: {}
          pull_request: {}
          workflow_dispatch: {}

        permissions:
          contents: read
          pages: write
          id-token: write

        # Allow only one concurrent deployment, skipping runs queued between the run in-progress and latest queued.
        # However, do NOT cancel in-progress runs as we want to allow these production deployments to complete.
        concurrency:
          group: "pages"
          cancel-in-progress: false

        jobs:
          build:
            runs-on: ubuntu-latest

            steps:
              - name: Checkout
                uses: actions/checkout@v4

              - name: Set up Ruby
                uses: ruby/setup-ruby@v1
                with:
                  ruby-version: '#{ruby_version}'
                  bundler-cache: true # runs 'bundle install' and caches installed gems automatically

              - name: Setup Pages
                id: pages
                uses: actions/configure-pages@v4

              - name: Build with Jekyll
                # Outputs to the './_site' directory by default
                run: |
                  bundle exec jekyll build --baseurl "${{ steps.pages.outputs.base_path }}" --source=docs --destination=docs/_site
                env:
                  JEKYLL_ENV: production

              - name: Upload artifact
                # Automatically uploads an artifact from the './_site' directory by default
                uses: actions/upload-pages-artifact@v3

                with:
                  path: docs/_site

                if: ${{ github.ref == 'refs/heads/main' }}

          deploy:
            environment:
              name: github-pages
              url: ${{ steps.deployment.outputs.page_url }}

            runs-on: ubuntu-latest

            needs: build

            if: ${{ github.ref == 'refs/heads/main' }}

            steps:
              - name: Deploy to GitHub Pages
                id: deployment
                uses: actions/deploy-pages@v4
      YAML
    end
    let(:expected_output) do
      <<~OUTPUT
        Adding GitHub pages workflow...
        Done!
      OUTPUT
    end

    before(:example) do
      allow(File).to receive_messages(
        exist?: false,
        write:  nil
      )
      allow(FileUtils).to receive(:mkdir_p)
    end

    it 'should define the method' do
      expect(command).to be_callable.with(0).arguments.and_keywords(:root_path)
    end

    it 'should return a passing result' do
      expect(command.call)
        .to be_a_passing_result
        .with_value(nil)
    end

    it 'should create the workflow directory' do
      command.call

      expect(FileUtils).to have_received(:mkdir_p).with(workflow_directory)
    end

    it 'should generate the workflow file' do
      command.call

      expect(File)
        .to have_received(:write)
        .with(workflow_file_path, expected_workflow)
    end

    it 'should print the report to STDOUT' do
      command.call

      expect(output_stream.string).to be == expected_output
    end

    it 'should not print to STDERR' do
      command.call

      expect(error_stream.string).to be == ''
    end

    describe 'with root_path: value' do
      let(:root_path) { '/path/to/root' }

      it 'should create the workflow directory' do
        command.call(root_path:)

        expect(FileUtils).to have_received(:mkdir_p).with(workflow_directory)
      end

      it 'should generate the workflow file' do
        command.call(root_path:)

        expect(File)
          .to have_received(:write)
          .with(workflow_file_path, expected_workflow)
      end
    end

    context 'when the workflow file already exists' do
      let(:expected_error) do
        SleepingKingStudios::Yard::Errors::FileAlreadyExists
          .new(path: workflow_file_path)
      end
      let(:expected_output) do
        <<~OUTPUT
          Adding GitHub pages workflow...
        OUTPUT
      end
      let(:expected_error_output) do
        <<~OUTPUT
          Error: #{expected_error.message}
        OUTPUT
      end

      before(:example) do
        allow(File)
          .to receive(:exist?)
          .with(workflow_file_path)
          .and_return(true)
      end

      it 'should return a failing result' do
        expect(command.call)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should not generate the workflow file' do
        command.call

        expect(File).not_to have_received(:write)
      end

      it 'should print the partial report to STDOUT' do
        command.call

        expect(output_stream.string).to be == expected_output
      end

      it 'should print the error report to STDERR' do
        command.call

        expect(error_stream.string).to be == expected_error_output
      end

      context 'when initialized with force: true' do
        let(:options) { super().merge(force: true) }
        let(:expected_output) do
          <<~OUTPUT
            Adding GitHub pages workflow...
            Done!
          OUTPUT
        end

        it 'should generate the workflow file' do
          command.call

          expect(File)
            .to have_received(:write)
            .with(workflow_file_path, expected_workflow)
        end

        it 'should print the report to STDOUT' do
          command.call

          expect(output_stream.string).to be == expected_output
        end

        it 'should not print to STDERR' do
          command.call

          expect(error_stream.string).to be == ''
        end
      end
    end

    context 'when initialized with dry_run: true' do
      let(:options) { super().merge(dry_run: true) }

      it 'should not create the workflow directory' do
        command.call

        expect(FileUtils).not_to have_received(:mkdir_p)
      end

      it 'should not generate the workflow file' do
        command.call

        expect(File).not_to have_received(:write)
      end

      it 'should print the report to STDOUT' do
        command.call

        expect(output_stream.string).to be == expected_output
      end

      it 'should not print to STDERR' do
        command.call

        expect(error_stream.string).to be == ''
      end
    end

    context 'when initialized with verbose: false' do
      let(:options) { super().merge(verbose: false) }

      it 'should not print to STDOUT' do
        command.call

        expect(output_stream.string).to be == ''
      end

      it 'should not print to STDERR' do
        command.call

        expect(error_stream.string).to be == ''
      end
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

  describe '#force?' do
    include_examples 'should define predicate', :force?, false

    context 'when initialized with force: false' do
      let(:options) { super().merge(force: false) }

      it { expect(command.force?).to be false }
    end

    context 'when initialized with force: true' do
      let(:options) { super().merge(force: true) }

      it { expect(command.force?).to be true }
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
