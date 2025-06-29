---
---

# SleepingKingStudios::Docs

SleepingKingStudios::Docs provides a CLI and tooling for generating a static website from your [YARD](https://rubydoc.info/gems/yard/file/README.md) documentation, powered by [Jekyll](https://jekyllrb.com/).

## Documentation

This is the documentation for the [current development build](https://github.com/sleepingkingstudios/sleeping_king_studios-docs) of SleepingKingStudios::Docs.

- For the most recent release, see [Version 0.2]({{site.baseurl}}/versions/0.2).
- For previous releases, see the [Versions]({{site.baseurl}}/versions) page.

## Tasks

SleepingKingStudios::Docs uses the `thor` gem to power its [CLI tasks]({{site.baseurl}}/tasks).

### Documentation

- [docs:generate]({{site.baseurl}}/tasks#docs-generate) &mdash; Generates the documentation files for each Ruby file in your project.
- [docs:update]({{site.baseurl}}/tasks#docs-update) &mdash; Updates existing documentation files.

### Installation

- [docs:install]({{site.baseurl}}/tasks#docs-install) &mdash; Installs the Jekyll application.
- [docs:install:templates]({{site.baseurl}}/tasks#docs-install-templates) &mdash; Installs or updates the Jekyll templates for YARD objects.
- [docs:install:workflow]({{site.baseurl}}/tasks#docs-install-workflow) &mdash; Installs or updates the GitHub actions workflow for deploying to Pages.

## Reference

For a full list of defined classes and objects, see [Reference](./reference).
