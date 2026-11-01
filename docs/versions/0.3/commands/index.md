---
breadcrumbs:
- name: Documentation
  path: "/"
- name: Versions
  path: "/versions"
- name: Version 0.3
  path: "/versions/0.3"
version: '0.3'
---

# Documentation Commands

SleepingKingStudios::Docs uses the <a href="https://www.sleepingkingstudios.com/cuprum-cli/" target="_blank">Cuprum::Cli</a> gem to power its commands.

The following CLI commands are used to generate and update the documentation for your project.

## Contents

- [Clobber](#clobber): Removes the reference files.
- [Check](#check): Compares the reference files to the code.
- [Document Version](#document-version): Generates reference files and copies static documentation.
- [Generate](#generate): Generates new reference files.
- [Update](#update): Updates existing reference files.

### See Also

- [Installation Commands](./installation)

## Clobber

The `clobber` command removes the generated reference files for the current or specified version. Any non-reference files (such as manual documentation) are unaffected, as are any files for other versions.

```bash
# Remove files for the current version.
bundle exec thor docs:jekyll:clobber

# Remove files for the specified version.
bundle exec thor docs:jekyll:clobber --version=0.1
```

The command defines the following options:

`docs_path`
: The `--docs-path=value` option allows customizing the root directory for the generated documentation files. The default value is `./docs`.

`dry_run`
: If the `--dry-run` flag is set, the command will not make any changes to the filesystem.

`quiet`
: If the `--quiet` flag is set, the command will not output its status to STDOUT.

`verbose`
: If the `--verbose` flag is set, the command will output additional information to STDOUT.

`version`
: The `--version=value` option allows setting a version for the removed documentation. If set, the files will be removed from namespaced directories.

[Back to Top](#)

## Check

The `check` command compares the project code with the generated reference files for the current or specified version.

```bash
# Check files for the current version.
bundle exec thor docs:jekyll:check

# Check files for the specified version.
bundle exec thor docs:jekyll:check --version=0.1
```

The check command checks for the the following documentation issues:

- Missing files, e.g. reference files for code that was *added* since the last time the documentation was generated.
- Extra files, e.g. reference files for code that was *removed* since the last time the documentation was generated.
- Changed files (using the file checksum), e.g. reference files for code that was *changed* since the last time the documentation was generated.

This command is best used in a CI step to verify that the generated documentation is up to date. Running this command on every pull request is recommended.

The command defines the following options:

`docs_path`
: The `--docs-path=value` option allows customizing the root directory for the generated documentation files. The default value is `./docs`.

`inspect_changes`
: If the `--inspect-changes` flag is set, then for each file that is listed as changed, the command will output the *expected* documentation for that file. This can be used to compare with the existing file to resolve unexpected errors.

`quiet`
: If the `--quiet` flag is set, the command will not output its status to STDOUT.

`verbose`
: If the `--verbose` flag is set, the command will output additional information to STDOUT.

`version`
: The `--version=value` option allows setting a version for the removed documentation. If set, the files from namespaced directories will be compared with the code.

[Back to Top](#)

## Document Version

The `document_version` command updates your documentation for a new release.

```bash
bundle exec thor docs:jekyll:document_version 0.1
```

When run, the command performs the following actions:

- Generates or updates the reference documentation for the version.
- Adds the version to the `versions` collection.
- Generates a `versions/#{version}` directory in `docs_path` and copies static documentation files into that directory, updating file breadcrumbs as needed.

Use the `document_version` command to quickly update your documentation for a new release.

The command requires a single argument, which is the version to generate documentation for. It also defines the following options:

`docs_path`
: The `--docs-path=value` option allows customizing the root directory for the generated documentation files. The default value is `./docs`.

`dry_run`
: If the `--dry-run` flag is set, the command will not make any changes to the filesystem.

`quiet`
: If the `--quiet` flag is set, the command will not output its status to STDOUT.

`verbose`
: If the `--verbose` flag is set, the command will also output the generated file contents to STDOUT.

[Back to Top](#)

## Generate

The `generate` command creates new reference files for each Ruby file in your project for the current or specified version. It will fail if there are any existing reference files - either call the [Clobber](#clobber) command first to clear any existing files, or use the [Update](#update) command to update existing files instead.

```bash
# Generate files for the current version.
bundle exec thor docs:jekyll:generate

# Generate files for the specified version.
bundle exec thor docs:jekyll:generate --version=0.1
```

The command defines the following options:

`docs_path`
: The `--docs-path=value` option allows customizing the root directory for the generated documentation files. The default value is `./docs`.

`dry_run`
: If the `--dry-run` flag is set, the command will not make any changes to the filesystem.

`quiet`
: If the `--quiet` flag is set, the command will not output its status to STDOUT.

`verbose`
: If the `--verbose` flag is set, the command will also output the generated file contents to STDOUT.

`version`
: The `--version=value` option allows setting a version for the removed documentation. If set, the files will be generated in namespaced directories.

[Back to Top](#)

## Update

The `update` command updates the reference files based on the current codebase. It will create files for new classes or methods, update existing files whose code has changed, and remove files whose code has been deleted.

```bash
# Generate files for the current version.
bundle exec thor docs:jekyll:update

# Generate files for the specified version.
bundle exec thor docs:jekyll:update --version=0.1
```

The command defines the following options:

`docs_path`
: The `--docs-path=value` option allows customizing the root directory for the generated documentation files. The default value is `./docs`.

`dry_run`
: If the `--dry-run` flag is set, the command will not make any changes to the filesystem.

`quiet`
: If the `--quiet` flag is set, the command will not output its status to STDOUT.

`verbose`
: If the `--verbose` flag is set, the command will also output the generated file contents to STDOUT.

`version`
: The `--version=value` option allows setting a version for the removed documentation. If set, the files will be generated in namespaced directories.

[Back to Top](#)
