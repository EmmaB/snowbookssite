#
#
# # Gems used only for assets and not required
# # in production environments by default.
# group :assets do
#   gem 'sass-rails',   '~> 3.2.3'
#   gem 'coffee-rails', '~> 3.2.1'
#
#   # See https://github.com/sstephenson/execjs#readme for more supported runtimes
#   # gem 'therubyracer', :platforms => :ruby
#
#   gem 'uglifier', '>= 1.0.3'
# end
#

source 'http://rubygems.org'

# Rails
gem "rails", '3.2.11'
gem 'rake', '0.9.2.2'
#, '~> 0.8.7'

# Basic libraries
gem "unicorn"
gem 'jquery-rails', '2.1.4'
gem 'nokogiri'
gem 'bundler'
gem "activesupport"
gem "heroku"
gem 'aws-s3'
gem 'aws-sdk' #required in 3.1.3 to get rake to work
gem 'hirefireapp'
gem 'newrelic_rpm', "~> 3.5.3.25"
gem 'modernizr-rails'
gem 'gocardless'

# Background processing
gem 'delayed_job_active_record' #required in 3.1.3 to get DJ to work
gem "SystemTimer", :require => "system_timer", :platforms => :ruby_18
gem "rack-timeout"
gem 'delayed_paperclip'    , '2.4.5.2' # , :git => 'git://github.com/tommeier/delayed_paperclip', :branch => 'fix_312'

# Views
gem 'haml'
gem 'rdiscount', "~> 1.6.8" #manually included -- it's a dependency of simple tooltip
gem 'simple-tooltip', "~> 0.0.2"
gem 'will_paginate', '~>3.0'
gem 'will_paginate-bootstrap', '0.2.1'
gem 'gritter_notices', '~>0.3.4' #, :git => 'git@github.com:ck3g/gritter_notices.git'
gem "ariane"
gem 'mercury-rails', :git => 'git://github.com/jejacks0n/mercury.git'
gem 'gvis', '>= 2.0.0'
gem "google_visualr", ">= 2.1"
# gem "gritter", "1.0.2"


group :assets do
  # gem "therubyracer"
  gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
  gem 'less-rails-bootstrap'
  gem 'less'
gem 'therubyracer'
end

gem "twitter-bootstrap-rails" # don't put in assets group for some stupid reason.
gem 'font-awesome-rails'
gem 'rabl'
gem 'gon'

# Authentication and authorisation
gem "cancan", '~> 1.6.7'
gem "devise" #, "~> 1.4.8"
gem 'devise_invitable', '~> 1.0.0'

# Barcodes
gem 'barby' #for generating barcodes
gem 'chunky_png' #for turning barcodes into png

# Forms
gem 'formtastic'
gem 'twitter_bootstrap_form_for'
gem 'client_side_validations', :git => "git://github.com/bcardarella/client_side_validations.git"
gem 'client_side_validations-formtastic'
gem 'cocoon' #adds link_to_add_association functionality in forms, so you can add nested fields using JS. https://github.com/nathanvda/cocoon
gem 'letsrate'
gem 'formtastic-bootstrap', " ~> 2.0.0"
gem 'active_link_to'

# Search
gem "ransack" #:git => "git://github.com/ernie/ransack.git"
gem 'pg_search'

# IO
gem "activerecord-import" #used in one off class methods for importing. Provides the .import method.
gem "csv_builder"
gem 'pdfkit'
gem 'wkhtmltopdf'
gem "rmagick"
gem 'paperclip', '~> 2.3'
gem 'paperclip-meta' # extends function of paperclip gem: saves default thumbnail image size info in appropriate table (in this case supportingresources)
# gem 'google_books'
gem "googlebooks"
gem "amazon-ecs"
gem 'acts_as_xlsx'
gem "prawn", :git => "git://github.com/prawnpdf/prawn.git"
gem 'activemodel-warnings'
gem "roo"

# Other
gem 'deep_cloneable', '~> 1.4.0'
gem "isbn"
gem 'wicked'
gem "strip_attributes", "~> 1.0"
gem "microformats_helper"
gem "sanitize"
gem 'paper_trail', '~> 2'
gem "best_in_place"
gem 'shortener'
gem 'twitter'
gem 'acts-as-taggable-on'


gem "yard" # yard server --reload for a server running on 8808

# Rails 3.1 - Asset Pipeline
gem 'json'
gem 'coffee-script'
gem 'sprockets-image_compressor', "~> 0.2.0"

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'yui-compressor'
  gem 'compass-rails'
end
# Rails 3.1 - Heroku
  gem 'pg'
  gem 'dalli', "~> 2.5.0"


group(:development, :test) do
gem 'simplecov', :require => false
  # gem "better_errors"
  # gem 'binding_of_caller'
  # gem 'meta_request'
  gem 'ruby-prof'
  gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git' # run with bundle exec annotate
  gem "rails-erd" # for creaating erd diagrams. Run with rake erd
  gem 'autotest'
  gem 'autotest-rails'
  gem 'ZenTest', '4.5.0'
  gem 'factory_girl', "~> 3.0.0"
  gem 'factory_girl_rails'
  gem 'faker', '0.3.1', :require => false
  gem 'launchy'
  gem 'rspec'
  gem 'rspec-core', :require => 'rspec/core'
  gem 'rspec-expectations', :require => 'rspec/expectations'
  gem 'rspec-mocks', :require => 'rspec/mocks'
  gem 'rspec-rails'
  gem 'spork'
  gem 'selenium-webdriver', '2.5.0'
  gem 'capybara'
  gem 'capybara-webkit'
  gem "fakes3"

end




