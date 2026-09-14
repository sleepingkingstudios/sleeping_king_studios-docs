# Changelog

# 0.3.0

Removed support for Ruby 3.1.

> **Warning**
>
> CLI commands are now namespaced in preparation for adding support for non-Jekyll site generators.

> **Upgrade Notes**
>
> Remove `load 'sleeping_king_studios/docs/tasks.rb'` from your `.thor` file and add:
>
> ```ruby
> require 'sleeping_king_studios/docs/jekyll'
>
> require 'cuprum/cli/integrations/thor/registry'
>
> registry = Cuprum::Cli::Integrations::Thor::Registry.new
>
> # Docs Commands
> registry.register SleepingKingStudios::Docs::Jekyll::Commands::Clobber
> registry.register SleepingKingStudios::Docs::Jekyll::Commands::Generate
> registry.register SleepingKingStudios::Docs::Jekyll::Commands::Install
> registry.register SleepingKingStudios::Docs::Jekyll::Commands::InstallTemplates
> registry.register SleepingKingStudios::Docs::Jekyll::Commands::InstallWorkflow
> registry.register SleepingKingStudios::Docs::Jekyll::Commands::Update
> ```
>
> Skip any commands that are not relevant for your project, such as installation commands for a project that already has a Jekyll application installed.

## Commands

Added dependency on `cuprum/cli` gem.

Refactored CLI Commands:

- Installation commands now use `Cuprum::Cli`.
- Installation commands moved to `Docs::Jekyll::Commands` namespace.
- Reference commands refactored and moved to `Docs::Jekyll::Commands` namespace.

Updated file templates.

# 0.2.1

Added support for Ruby 4.0.

# 0.2.0

> **Upgrade Notes**
>
> Add the following to your `_config.yml` files:
>
> ```markdown
> plugins:
>   - sleeping_king_studios/docs/jekyll/plugins/required
> ```

- Improved handling of method names with characters that are not valid for HTML anchors, such as `[]`, `=`, and `?`.

# 0.1.0

Initial development release.
