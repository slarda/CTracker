source 'http://rubygems.org'

gem 'rails', '>= 4.2.6'
gem 'mysql2', '>= 0.4.3'
gem 'sass-rails', '>= 5.0.4'
gem 'sass', '>= 3.4.21'
gem 'uglifier', '>= 2.7.2'
gem 'coffee-rails', '>= 4.1.1'
gem 'jquery-rails', '>= 4.1.0'
gem 'jbuilder', '>= 2.4.1'

gem 'sprockets', '>= 3.5.2'
gem 'sprockets-rails', '>= 3.0.4'
gem 'angular-rails-templates'
gem 'slim-rails'
gem 'slim_assets', '>= 0.0.2'
gem 'tilt', '>= 1.4.1'

gem 'bootstrap-sass', '>= 3.3.6'
gem 'sorcery', '>= 0.9.1'
gem 'activeadmin', '>= 1.0.0.pre2'
gem 'geocoder', '>= 1.3.1'
gem 'dalli', '>= 2.7.6'
gem 'cancancan', '>= 1.13.1'
gem 'pretender', '>= 0.1.0'

gem 'devise', '>= 3.5.6'
gem 'country_select', '>= 2.5.1'

gem 'carrierwave', '>= 0.10.0'
gem 'carrierwave-crop', '>= 0.1.2'
gem 'mini_magick', '>= 4.4.0'

# TODO: Convert to rails-assets with Angular 1.3.x
gem 'angularjs-file-upload-rails', '>= 1.1.6'

gem 'delayed_job_active_record', '>= 4.1.0'

gem 'namae', '>= 0.10.1'
gem 'compass-rails', '>= 3.0.1'
gem 'compass', '>= 1.0.3'
gem 'compass-core'
gem 'newrelic_rpm', '>= 3.15.0.314'

gem 'sidekiq'
gem 'redmon'

# CORS is required for cross-domain (dev-to-prod AJAX requests on articles)
gem 'rack-cors', '>= 0.4.0', :require => 'rack/cors'

# See https://github.com/thoughtbot/bourbon/issues/615
gem 'bourbon', '>= 4.2.1'

# Angular.js held back due to angular-ui bootstrap issue:
# https://github.com/angular-ui/bootstrap/issues/3896

source 'https://rails-assets.org' do
  gem 'rails-assets-angular', '= 1.3.15'
  gem 'rails-assets-angular-resource', '= 1.3.15'
  gem 'rails-assets-angular-route', '= 1.3.15'
  gem 'rails-assets-angular-sanitize', '= 1.3.15'
  gem 'rails-assets-angular-animate', '= 1.3.15'
  gem 'rails-assets-angular-touch', '= 1.3.15'
  gem 'rails-assets-angular-simple-logger'
  gem 'rails-assets-angular-media-queries', '>= 0.6.0'
  gem 'rails-assets-checklist-model', '>= 0.9.0'
  gem 'rails-assets-font-awesome', '>= 4.5.0'
  gem 'rails-assets-weather-icons', '>= 2.0.10'
  gem 'rails-assets-animate.css', '>= 3.5.1'
  gem 'rails-assets-normalize-scss', '>= 3.0.3'
  gem 'rails-assets-modernizr-ra', '>= 2.8.3'
  # gem 'rails-assets-angular-ui-bootstrap', '>= 0.12.1'
  gem 'rails-assets-easypie', '>= 2.1.6'
  gem 'rails-assets-lodash', '= 3.10.1' # TODO: 4.x breaks google maps - see https://trello.com/c/WGeYht5j/232-every-time-i-visit-a-club-page-the-map-is-showing-a-weird-address
  gem 'rails-assets-angular-ui--angular-google-maps', '>= 2.2.1'
  gem 'rails-assets-angular-truncate-asset', '>= 0.1.1'
  gem 'rails-assets-angulartics-google-analytics', '>= 0.1.4'
  gem 'rails-assets-angular-easyfb', '>= 1.4.1'
end

gem 'angular-ui-bootstrap-rails', '= 0.12.0' #, path: '../angular-ui-bootstrap-rails' # github: 'wtfiwtz/angular-ui-bootstrap-rails', branch: 'fixes/backdrop'

group :development do
  gem 'letter_opener', '>= 1.4.1'
  gem 'spring', '>= 1.6.4'
  gem 'capistrano', '>= 3.4.0'
  gem 'capistrano-rails', '>= 1.1.6'
  gem 'capistrano-bundler', '>= 1.1.4'
  gem 'capistrano-sidekiq'
  gem 'capistrano-rvm'
  # gem 'capistrano-passenger', '>= 0.0.1'
end

group :development, :test do
  gem 'rspec-rails', '>= 3.4.2'
  gem 'factory_girl_rails', '>= 4.6.0'
  gem 'protractor-rails', '>= 0.0.18'
  gem 'database_cleaner', '>= 1.5.1'
  gem 'shoulda', '>= 3.5.0'
  gem 'mocha', '>= 1.1.0'
  gem 'simplecov', '>= 0.11.2', require: false
end

group :development, :test do
  gem 'railroady', '>= 1.4.2'
  gem 'rubocop', '>= 0.37.2'
end

gem 'sdoc', '>= 0.4.1', group: :doc

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use ActiveModel has_secure_password
# gem 'bcrypt', '>= 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'sqlite3'