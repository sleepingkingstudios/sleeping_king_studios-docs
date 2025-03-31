# SleepingKingStudios::Docs

Tools for generating a versioned documentation site from YARD docs.

<blockquote>
  Read The
  <a href="https://www.sleepingkingstudios.com/sleeping_king_studios-docs" target="_blank">
    Documentation
  </a>
</blockquote>

## About

### Compatibility

SleepingKingStudios::Yard is tested against Ruby (MRI) 3.1 through 3.4.

### Documentation

Documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem. Online documentation for current and previous versions is available at [sleepingkingstudios.com](https://www.sleepingkingstudios.com/sleeping_king_studios-docs).

### License

Copyright (c) 2022-2025 Rob Smith

SleepingKingStudios::Docs is released under the [MIT License](https://opensource.org/licenses/MIT).

### Contribute

The canonical repository for this gem is located at https://github.com/sleepingkingstudios/sleeping_king_studios-docs.

To report a bug or submit a feature request, please use the [Issue Tracker](https://github.com/sleepingkingstudios/sleeping_king_studios-docs/issues).

To contribute code, please fork the repository, make the desired updates, and then provide a [Pull Request](https://github.com/sleepingkingstudios/sleeping_king_studios-docs/pulls). Pull requests must include appropriate tests for consideration, and all code must be properly formatted.

### Code of Conduct

Please note that the `SleepingKingStudios::Docs` project is released with a [Contributor Code of Conduct](https://github.com/sleepingkingstudios/sleeping_king_studios-docs/blob/master/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

## Installation

Add the docs dependencies to your Gemfile:

```ruby
group :docs do
  gem 'jekyll'
  gem 'sleeping_king_studios-docs'
  gem 'webrick'
  gem 'yard',  require: false
end
```

You may also want to consider adding a [Jekyll theme](https://jekyllrb.com/docs/themes/#pick-up-a-theme) and/or a Markdown parser (Kramdown is recommended).

Generate or update your `tasks.thor` file:

```ruby
# frozen_string_literal: true

load 'sleeping_king_studios/docs/tasks.rb'
```

### Installation Script

Use the installation script to quickly install the Jekyll application:

```bash
bundle exec thor docs:install --name="Orichalcum" --description="A real gem." --repository="www.example.com"
```

You can also install a GitHub pages workflow to automatically deploy to GitHub Pages. Make sure that Pages is configured for your repository to deploy from a GitHub action.

```bash
bundle exec thor docs:install:workflow
```

## Generating Documentation

Use the [Thor CLI](https://www.sleepingkingstudios.com/sleeping_king_studios-docs/tasks#documentation) to generate and update the reference documentation for your project.

The `docs:generate` task will generate the documentation files for each Ruby file in your project. It does not update any existing files by default, so if you have made changes to existing code use the `docs:update` command or use the `--force` command line option.

```bash
bundle exec thor docs:generate
```

The `docs:update` task will generate and updates th documentation files for each Ruby file in your project. It will update any existing documentation files.

```bash
bundle exec thor docs:update
```

### Versioned Documentation

You can pass a `--version` flag to the `docs:generate` or `docs:update` tasks, indicating that the generated documentation is for a specific version of the software. This is recommended for each major and minor release; patch-level changes may or may not need to be documented depending on the degree of change.

```bash
bundle exec thor docs:generate --version="1.2.3"
```

Any non-reference documentation should be copied into the newly created version scope. Make sure to update the `versions/index.md` file to link the new scope.
