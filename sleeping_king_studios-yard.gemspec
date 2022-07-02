# frozen_string_literal: true

$LOAD_PATH << './lib'

require 'sleeping_king_studios/yard/version'

Gem::Specification.new do |gem|
  gem.name        = 'sleeping_king_studios-yard'
  gem.version     = SleepingKingStudios::Yard::VERSION
  gem.summary     = 'Tooling for working with YARD documentation.'

  description = <<~DESCRIPTION
    Tooling for working with YARD documentation.
  DESCRIPTION
  gem.description = description.strip.gsub(/\n +/, ' ')
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.metadata = {
    'bug_tracker_uri'       => 'https://github.com/sleepingkingstudios/sleeping_king_studios-yard/issues',
    'source_code_uri'       => 'https://github.com/sleepingkingstudios/sleeping_king_studios-yard',
    'rubygems_mfa_required' => 'true'
  }

  gem.required_ruby_version = '>= 2.7.0'
  gem.require_path = 'lib'
  gem.files        = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.add_runtime_dependency 'sleeping_king_studios-tools', '~> 1.0'

  gem.add_development_dependency 'rspec',                       '~> 3.11'
  gem.add_development_dependency 'rspec-sleeping_king_studios', '~> 2.7'
  gem.add_development_dependency 'rubocop',                     '~> 1.31'
  gem.add_development_dependency 'rubocop-rspec',               '~> 2.11'
  gem.add_development_dependency 'simplecov',                   '~> 0.21'
end
