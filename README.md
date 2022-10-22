# SleepingKingStudios::Yard

Tooling for working with YARD documentation.

## Generating Documentation

To generate documentation, use the `Generate` command:

```ruby
require 'sleeping_king_studios/yard'

docs_path = './docs'
command   =
  SleepingKingStudios::Yard::Commands::Generate.new(docs_path: docs_path)

command.call
```

You can also pass an optional `:file_path` keyword to `#call`, which specifies the location from which `YARD` will parse the source files.

```ruby
command.call(file_path: './app')
```

The `Generate` command defines the following constructor options:

- **dry_run:** *Boolean*. If `true`, the command does not write any files to disk. Defaults to `false`.
- **force:** *Boolean*. If `true`, the command will overwrite any existing files. Defaults to `false`.
- **template_path:** *String*. The relative path to the Jekyll templates for each data type; used when generating the reference Markdown files. Defaults to `reference`.
- **verbose:** *Boolean*. If `true`, the command will write a status update to `STDOUT` for each file written to disk. Defaults to `false`.
- **version:** *String*. If provided, the command will scope the generated data and reference files to a versioned directory, and writes the version directly to data files (in the file data) and reference files (in the template data). Defaults to `nil`.
