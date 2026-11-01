---
breadcrumbs:
- name: Documentation
  path: "/"
- name: Versions
  path: "/versions"
- name: Version 0.3
  path: "/versions/0.3"
- name: Commands
  path: "/versions/0.3/commands"
version: '0.3'
---

# Installation Commands

The following commands are used to install or update the Jekyll application to serve your generated documentation.

## Contents

- [Backfill Versions](#backfill-versions): Populates the `versions` collection for Jekyll sites generated using previous versions.
- [Install](#install): Installs the Jekyll app for the first time.
- [Install Templates](#install-templates): Installs or updates the Jekyll templates.
- [Install Workflow](#install-workflow): Installs a sample GitHub Action workflow for deploying to GitHub Pages.

### See Also

- [Documentation Commands](../commands)

## Backfill Versions

The `backfill_versions` command populates the `versions` collection for Jekyll sites generated using previous versions.

```bash
bundle exec thor docs:jekyll:backfill_versions
```

After running the command, it will display additional instructions for updating the Jekyll application.

The command defines the following options:

`docs_path`
: The `--docs-path=VALUE` option allows customizing the root directory for the generated documentation files. The default value is `./docs`.

`dry_run`
: If the `--dry-run` flag is set, the command will not make any changes to the filesystem.

`quiet`
: If the `--quiet` flag is set, the command will not output its status to STDOUT.

`verbose`
: If the `--verbose` flag is set, the command will also output the generated file contents to STDOUT.

[Back to Top](#)

## Install

The `install` command is used to install the Jekyll app for the first time.

```bash
bundle exec thor docs:jekyll:install
```

The command installs and configures a new `Jekyll` application. It can optionally add the required dependencies to the `Gemfile` and needed exclusions to the local `.gitignore` file.

The command defines the following options:

`docs_path`
: The `--docs-path=value` option allows customizing the root directory for the Jekyll application. The default value is `./docs`.

`dry_run`
: If the `--dry-run` flag is set, the command will not make any changes to the filesystem.

`quiet`
: If the `--quiet` flag is set, the command will not output its status to STDOUT.

`skip_gemfile`
: If the `--skip-gemfile` flag is set, the command will not add the dependencies to the `Gemfile`.

`skip_gitignore`
: If the `--skip-gitignore` flag is set, the command will not update the local `.gitignore` file.

`skip_templates`
: If the `--skip-templates` flag is set, the command will not install the default templates.

`verbose`
: If the `--verbose` flag is set, the command will also output the generated file contents to STDOUT.

`workflow`
: If the `--workflow` flag is set, the command will also [install a sample GitHub Action workflow](#install-workflow) for deploying to GitHub Pages.

[Back to Top](#)

## Install Templates

The `install_templates` command installs or updates the Jekyll templates.

```bash
bundle exec thor docs:jekyll:install_templates
```

The command defines the following options:

`docs_path`
: The `--docs-path=VALUE` option allows customizing the root directory for the generated documentation files. The default value is `./docs`.

`dry_run`
: If the `--dry-run` flag is set, the command will not make any changes to the filesystem.

`force`
: If the `--force` flag is set, the command will overwrite existing templates.

`ignore_existing`
: If the `--ignore-existing` flag is set, the command will ignore existing templates instead of raising an Exception.

`quiet`
: If the `--quiet` flag is set, the command will not output its status to STDOUT.

`verbose`
: If the `--verbose` flag is set, the command will also output the generated file contents to STDOUT.

[Back to Top](#)

## Install Workflow

The `install_workflow` command installs a sample GitHub Action workflow for deploying to GitHub Pages.

```bash
bundle exec thor docs:jekyll:install_workflow
```

The command defines the following options:

`dry_run`
: If the `--dry-run` flag is set, the command will not make any changes to the filesystem.

`file_path`
: The `--file-path=VALUE` option allows overriding the output path for the workflow action. The default is `'.github/workflows/deploy-pages.yml'`.

`ruby_version`
: The `--ruby-version=VALUE` option allows configuring the Ruby version used to run the workflow. The default is the current Ruby version.

`quiet`
: If the `--quiet` flag is set, the command will not output its status to STDOUT.

`verbose`
: If the `--verbose` flag is set, the command will also output the generated file contents to STDOUT.

[Back to Top](#)
