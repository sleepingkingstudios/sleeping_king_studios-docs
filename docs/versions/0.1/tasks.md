---
breadcrumbs:
  - name: Documentation
    path: '../../'
  - name: Versions
    path: '../'
  - name: '0.1'
    path: './'
---

# Tasks

SleepingKingStudios::Docs uses the `thor` gem to power its CLI.

- [Documentation](#documentation)
  - [docs:generate](#docs-generate) &mdash; Generates the documentation files for each Ruby file in your project.
  - [docs:update](#docs-update) &mdash; Updates existing documentation files.
- [Installation](#installation)
  - [docs:install](#docs-install) &mdash; Installs the Jekyll application.
  - [docs:install:templates](#docs-install-templates) &mdash; Installs or updates the Jekyll templates for YARD objects.
  - [docs:install:workflow](#docs-install-workflow) &mdash; Installs or updates the GitHub actions workflow for deploying to Pages.

<a id="documentation" />

## Documentation

The following CLI tasks are used to generate and update the documentation for your project.

<a id="docs-generate" />

### docs:generate

The `docs:generate` task generates the documentation files for each Ruby file in your project. It does not update any existing files by default, so if you have made changes to existing code use the `docs:update` command (below) or use the `--force` command line option.

```bash
bundle exec thor docs:generate
```

The task defines the following options:

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

<a id="docs-update" />

### docs:update

The `docs:update` task generates and updates the documentation files for each Ruby file in your project. It will update any existing documentation files.

```bash
bundle exec thor docs:update
```

The task defines the following options:

docs_path
: The `--docs-path=value` option allows customizing the root directory for the generated documentation files. The default value is `./docs`.

dry_run
: If the `--dry-run` flag is set, the task will not make any changes to the filesystem.

verbose
: If the `--skip-verbose` flag is set, the task will not output its status to STDOUT.

version
: The `--version=value` option allows setting a version for the generated documentation. If set, the files will be generated in namespaced directories and set the `version` flag in the YAML files.

<a id="installation" />

## Installation

<a id="docs-install" />

### docs:install

The `docs:install` task installs the Jekyll application.

```bash
bundle exec thor docs:install --name="Orichalcum" --description="A real gem." --repository="www.example.com"
```

The task defines the following options:

description
: The `--description=value` option allows for setting a description for the library. This is used when generating the template files.

docs_path
: The `--docs-path=value` option allows customizing the root directory for the generated documentation files. The default value is `./docs`.

dry_run
: If the `--dry-run` flag is set, the task will not make any changes to the filesystem.

name
: The `--name=value` option allows for setting a name for the library. This is used when generating the template files.

repository
: The `--repository=value` option allows for setting a repository URL for the library. This is used when generating the template files.

root_path
: The `--root-path=value` option allows setting the root directory for the library. It is used when updating the `.gitignore` file. The default value is the working directory.

verbose
: If the `--skip-verbose` flag is set, the task will not output its status to STDOUT.

<a id="docs-install-templates" />

### docs:install:templates

The `docs:install:templates` command installs or updates the Jekyll templates for YARD objects.

```bash
bundle exec thor docs:install:templates
```

The `docs:install` command defines the following options:

docs_path
: The `--docs-path=value` option allows customizing the root directory for the generated documentation files. The default value is `./docs`.

dry_run
: If the `--dry-run` flag is set, the task will not make any changes to the filesystem.

force
: If the `--force` flag is set, the task will overwrite any existing templates.

verbose
: If the `--skip-verbose` flag is set, the task will not output its status to STDOUT.

<a id="docs-install-workflow" />

### docs:install:workflow

The `docs:install:workflow` command installs or updates the GitHub actions workflow for deploying to Pages.

```bash
bundle exec thor docs:install:workflow
```

The `docs:install:workflow` command defines the following options:

dry_run
: If the `--dry-run` flag is set, the task will not make any changes to the filesystem.

force
: If the `--force` flag is set, the task will overwrite an existing workflow.

root_path
: The `--root-path=value` option allows setting the root directory for the library. The default value is the working directory.

verbose
: If the `--skip-verbose` flag is set, the task will not output its status to STDOUT.

{% include breadcrumbs.md %}
