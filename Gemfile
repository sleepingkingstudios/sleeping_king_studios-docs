# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'cuprum',
  branch: 'main',
  git:    'https://github.com/sleepingkingstudios/cuprum'
gem 'sleeping_king_studios-tasks', '~> 0.4', '>= 0.4.1'

group :development, :test do
  gem 'byebug', '~> 11.1'

  gem 'rspec', '~> 3.13'
  gem 'rspec-sleeping_king_studios', '~> 2.8'
  gem 'rubocop', '~> 1.77'
  gem 'rubocop-rspec', '~> 3.6'
  gem 'simplecov', '~> 0.22'
end

group :docs do
  gem 'jekyll', '~> 4.4'
  gem 'jekyll-theme-dinky', '~> 0.2'

  # Use Kramdown to parse GFM-dialect Markdown.
  gem 'kramdown-parser-gfm', '~> 1.1'

  # Use Webrick as local content server.
  gem 'webrick', '~> 1.8'

  gem 'yard', '~> 0.9',  require: false
end
