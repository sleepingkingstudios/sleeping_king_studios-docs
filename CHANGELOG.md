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
> registry.register SleepingKingStudios::Docs::Jekyll.commands
>
> # Installation Commands (Creating or Updating Projects)
> registry.register SleepingKingStudios::Docs::Jekyll.install_commands
> ```
>
> Backfill any existing versions using `thor docs:jekyll:backfill_versions`.

## Commands

Added dependency on `cuprum/cli` gem.

Refactored CLI Commands:

- Installation commands now use `Cuprum::Cli`.
- Installation commands moved to `Docs::Jekyll::Commands` namespace.
- Reference commands refactored and moved to `Docs::Jekyll::Commands` namespace.

Updated file templates.

## Jekyll

Updated site configuration to include project metadata, including name, description, and repository information.

Added `_versions` collection for tracking documented versions.

Added updated site templates.

- Updated page breadcrumbs to be relative to the root path.
- Updated named headers to reference project metadata.
- Updated versions page to enumerate documented versions.

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
