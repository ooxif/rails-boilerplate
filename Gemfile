# frozen_string_literal: true

# - Rails 自身が利用する gem (Rails gem) と、
#   アプリケーションが独自に使う gem (Custom gem) は分けて記述してください。
# - グループごとに、 A-Z 順に記載してください。

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Rails gems
gem 'bootsnap', '>= 1.4.2', require: false
gem 'jbuilder', '~> 2.7'
gem 'mysql2', '>= 0.4.4'
gem 'puma', '~> 4.1'
gem 'rails', '~> 6.0.2', '>= 6.0.2.1'
gem 'rails-i18n', '~> 6.0.0'
gem 'sass-rails', '>= 6'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 4.0'

# Custom gems

group :development, :test do
  # Rails gems
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # Custom gems
  gem 'erb_lint', require: false
  gem 'rspec-rails', '>= 4.0.0.beta3', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  # Rails gems
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'

  # Custom gems
  gem 'spring-commands-rspec'
  gem 'spring-commands-rubocop'
end

group :test do
  # Rails gems
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
