source 'https://rubygems.org'

gem 'rails', '4.1.1'
gem 'jquery-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby
gem 'haml', '~> 4.0.5'
gem 'haml-rails', '~> 0.5.3'
gem 'less-rails', '~> 2.5.0'
gem 'sass-rails', '~> 4.0.3'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'turbolinks'

gem 'redcarpet' # Markdown processing
gem 'devise' # User authentication
gem 'mechanize' # Read-it-later entry parsing
gem 'paperclip', '~> 4.1' # Uploads to read-later
gem 'aws-sdk', '~> 1.42' # Store attachments in S3

group :production do
  gem 'mysql2', '~> 0.3.15'
  gem 'unicorn', '~> 4.8.2'
end

group :staging do
  gem 'pg'
  gem 'rails_12factor'
end

group :staging, :production do
  gem 'newrelic_rpm'
end

group :test, :development do
  gem 'spring'
  gem 'sqlite3'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'coveralls', '~> 0.7.0'
end

group :staging, :test, :development do
  gem 'thin'
end

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0',          group: :doc
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
