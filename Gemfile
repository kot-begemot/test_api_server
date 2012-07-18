source 'http://rubygems.org'

gem 'rails', '3.1.0'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'
gem "state_machine", "~> 1.1.2"
gem "rabl", "~> 0.6.13"

gem "delayed_job_active_record", "~> 0.3.2"

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'minitest', '3.2.0'
  gem "mocha", "~> 0.12.0", :require => false
  gem "capybara", "~> 1.1.2"
  if RUBY_VERSION >= '1.9.0'
    gem "debugger", "~> 1.1.3"
  else
    gem 'ruby-debug'
  end
end

group :test, :development do
  gem 'execjs'
  gem 'therubyracer'
end
