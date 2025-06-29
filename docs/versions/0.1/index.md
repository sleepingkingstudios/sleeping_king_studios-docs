---
breadcrumbs:
  - name: Documentation
    path: '../../'
  - name: Versions
    path: '../'
---

# SleepingKingStudios::Docs

SleepingKingStudios::Docs provides a CLI and tooling for generating a static website from your [YARD](https://rubydoc.info/gems/yard/file/README.md) documentation, powered by [Jekyll](https://jekyllrb.com/).

## Documentation

This is the documentation for Version 0.1 of SleepingKingStudios::Docs.

- For the current development build, see [Documentation]({{site.baseurl}}/).
- For previous releases, see the [Versions]({{site.baseurl}}/versions) page.

## Tasks

SleepingKingStudios::Docs uses the `thor` gem to power its [CLI tasks](./tasks).

### Documentation

- [docs:generate](./tasks#docs-generate) &mdash; Generates the documentation files for each Ruby file in your project.
- [docs:update](./tasks#docs-update) &mdash; Updates existing documentation files.

### Installation

- [docs:install](./tasks#docs-install) &mdash; Installs the Jekyll application.
- [docs:install:templates](./tasks#docs-install-templates) &mdash; Installs or updates the Jekyll templates for YARD objects.
- [docs:install:workflow](./tasks#docs-install-workflow) &mdash; Installs or updates the GitHub actions workflow for deploying to Pages.

## Reference

For a full list of defined classes and objects, see [Reference](./reference).
