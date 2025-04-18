# frozen_string_literal: true

$LOAD_PATH << './lib'

require 'sleeping_king_studios/docs/version'

Gem::Specification.new do |gem|
  gem.name        = 'sleeping_king_studios-docs'
  gem.version     = SleepingKingStudios::Docs::VERSION
  gem.summary     =
    'Tools for generating a versioned documentation site from YARD docs.'

  description = <<~DESCRIPTION
    SleepingKingStudios::Docs provides a CLI and tooling for generating a static
    website from your YARD documentation, powered by Jekyll.
  DESCRIPTION
  gem.description = description.strip.gsub(/\n +/, ' ')
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.metadata = {
    'bug_tracker_uri'       => 'https://github.com/sleepingkingstudios/sleeping_king_studios-docs/issues',
    'source_code_uri'       => 'https://github.com/sleepingkingstudios/sleeping_king_studios-docs',
    'rubygems_mfa_required' => 'true'
  }

  gem.required_ruby_version = '~> 3.1'
  gem.require_path = 'lib'
  gem.files        =
    Dir[
      'lib/**/*.rb',
      'lib/**/*.treetop',
      'lib/sleeping_king_studios/docs/templates/**/*.md',
      'lib/sleeping_king_studios/docs/templates/**/*.md.erb',
      'lib/sleeping_king_studios/docs/templates/**/*.yml',
      'lib/sleeping_king_studios/docs/templates/**/*.yml.erb',
      'LICENSE',
      '*.md'
    ]

  gem.add_runtime_dependency 'cuprum', '~> 1.0'
  gem.add_runtime_dependency 'erubi', '~> 1.13'
  gem.add_runtime_dependency 'sleeping_king_studios-tools', '~> 1.2'
  gem.add_runtime_dependency 'thor', '~> 1.3'
  gem.add_runtime_dependency 'treetop', '~> 1.6'
  gem.add_runtime_dependency 'yard', '~> 0.9'
end
