# SleepingKingStudios::Docs

Tools for generating a versioned documentation site from YARD docs.

<blockquote>
  Read The
  <a href="https://www.sleepingkingstudios.com/sleeping_king_studios-docs" target="_blank">
    Documentation
  </a>
</blockquote>

## Installation

Add the docs dependencies to your Gemfile:

```ruby
group :doc do
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
