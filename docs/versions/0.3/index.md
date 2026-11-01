---
breadcrumbs:
- name: Documentation
  path: "/"
- name: Versions
  path: "/versions"
version: '0.3'
---

# {{ site.project_metadata.name }}

SleepingKingStudios::Docs provides a CLI and tooling for generating a static website from your [YARD](https://rubydoc.info/gems/yard/file/README.md) documentation, powered by [Jekyll](https://jekyllrb.com/).

## Documentation

{% include pages/index-versions.md %}

## Installation

Add the docs dependencies to your Gemfile:

```ruby
# Ensure that the CLI tool is available in development environment.
gem 'sleeping_king_studios-docs', groups: %w[docs development]

group :docs do
  gem 'jekyll'
  gem 'webrick'
  gem 'yard',  require: false
end
```

You may also want to consider adding a [Jekyll theme](https://jekyllrb.com/docs/themes/#pick-up-a-theme) and/or a Markdown parser (Kramdown is recommended).

Generate or update your `tasks.thor` file:

```ruby
# frozen_string_literal: true

require 'cuprum/cli/integrations/thor/registry'

registry = Cuprum::Cli::Integrations::Thor::Registry.new

require 'sleeping_king_studios/docs/jekyll'

# Docs Commands
registry.register SleepingKingStudios::Docs::Jekyll.commands

# Installation Commands (Creating or Updating Projects)
registry.register SleepingKingStudios::Docs::Jekyll.install_commands
```

Use the installation script to quickly install the Jekyll application:

```bash
bundle exec thor docs:jekyll:install
```

You can also install a GitHub pages workflow to automatically deploy to GitHub Pages. Make sure that Pages is configured for your repository to deploy from a GitHub action.

```bash
bundle exec thor docs:jekyll:install_workflow
```

## Generating Documentation


Use the [Thor CLI](./commands) to generate and update the reference documentation for your project.

The `docs:jekyll:generate` task will generate the documentation files for each Ruby file in your project.

```bash
bundle exec thor docs:jekyll:generate
```

The `docs:jekyll:update` task will generate and update the documentation files for each Ruby file in your project. It will update any existing documentation files and remove old files that no longer correspond to objects or methods in the code.

```bash
bundle exec thor docs:jekyll:update
```

### Versioned Documentation

You can generate reference docs and copy non-release documentation into the newly created version scope using the `document_version` command. This is recommended for each major and minor release; patch-level changes may or may not need to be documented depending on the degree of change.

```bash
bundle exec thor docs:jekyll:document_version "1.2.3"
```

You can also pass a `--version` flag to the `docs:jekyll:generate` or `docs:jekyll:update` tasks, indicating that the generated documentation is for a specific version of the software.

```bash
bundle exec thor docs:jekyll:generate --version="1.2.3"
```

## Tasks

SleepingKingStudios::Docs uses the <a href="https://www.sleepingkingstudios.com/cuprum-cli/" target="_blank">Cuprum::Cli</a> gem to power its [commands](./commands).

### Documentation

- [docs:jekyll:clobber](./commands#clobber) &mdash; Removes the reference files.
- [docs:jekyll:check](./commands#check) &mdash; Compares the reference files to the code.
- [docs:jekyll:document_version](./commands#document-version) &mdash; Generates reference files and copies static documentation.
- [docs:jekyll:generate](./commands#generate) &mdash; Generates new reference files.
- [docs:jekyll:update](./commands#update) &mdash; Updates existing reference files.

### Installation

- [docs:jekyll:backfill_versions](./commands/installation#backfill-versions) &mdash; Populates the `versions` collection for Jekyll sites generated using previous versions.
- [docs:jekyll:install](./commands/installation#install) &mdash; Installs the Jekyll app for the first time.
- [docs:jekyll:install_templates](./commands/installation#install-templates) &mdash; Installs or updates the Jekyll templates.
- [docs:install_workflow](./commands/installation#install-workflow) &mdash; Installs a sample GitHub Action workflow for deploying to GitHub Pages.

## Reference

For a full list of defined classes and objects, see [Reference](./reference).
