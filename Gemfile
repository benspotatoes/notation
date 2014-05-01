source 'https://rubygems.org'

gem 'rails', '4.1.0'
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

group :production do
  gem 'mysql2', '~> 0.3.15'
  gem 'unicorn', '~> 4.8.2'
end

group :test, :development do
  gem 'thin'
  gem 'sqlite3'
  gem 'spring'
end

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0',          group: :doc
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development