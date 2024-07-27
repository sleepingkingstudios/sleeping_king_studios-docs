# SleepingKingStudios::Yard

Tooling for working with YARD documentation.

## Installation

Add the docs dependencies to your Gemfile:

```ruby
group :doc do
  gem 'sleeping_king_studios-yard'
  gem 'thor'
  gem 'yard'
end
```

Generate or update your `tasks.thor` file:

```ruby
# frozen_string_literal: true

load 'sleeping_king_studios/yard/tasks.rb'
```

## Generating Documentation

Use the `Thor` CLI to generate documentation. The `docs:generate` task will create documentation for new files, while `docs:update` will also update existing file documentation.

## CLI Tasks

The gem defines a `Thor` CLI for generating documentation. To view the defined commands, run `bundle exec thor list`; all of the tasks for this gem are defined under the `docs:` namespace.

### docs:generate

The `docs:generate` task generates the documentation files for each Ruby file in your project. It does not update any existing files by default, so if you have made changes to existing code use the `docs:update` command (below) or use the `--force` command line option.

```bash
bundle exec thor docs:generate
```

The `docs:generate` command defines the following options:

docs_path
: The `--docs-path=value` option allows customizing the root directory for the generated documentation files. The default value is `./docs`.

dry_run
: If the `--dry-run` flag is set, the task will not make any changes to the filesystem.

force
: If the `--force` flag is set, the task will overwrite previously generated files.

verbose
: If the `--skip-verbose` flag is set, the task will not output its status to STDOUT.

version
: The `--version=value` option allows setting a version for the generated documentation. If set, the files will be generated in namespaced directories and set the `version` flag in the YAML files.

### docs:update

The `docs:update` task generates and updates the documentation files for each Ruby file in your project. It will update any existing documentation files.

```bash
bundle exec thor docs:update
```

The `docs:update` command defines the following options:

docs_path
: The `--docs-path=value` option allows customizing the root directory for the generated documentation files. The default value is `./docs`.

dry_run
: If the `--dry-run` flag is set, the task will not make any changes to the filesystem.

verbose
: If the `--skip-verbose` flag is set, the task will not output its status to STDOUT.

version
: The `--version=value` option allows setting a version for the generated documentation. If set, the files will be generated in namespaced directories and set the `version` flag in the YAML files.
