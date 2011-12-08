source "http://rubygems.org"

gem "rails", "3.1.3"
gem "jquery-rails"

group :assets do
  gem "sass-rails", "~> 3.1.5"
  gem "coffee-rails", "~> 3.1.1"
  gem "uglifier", ">= 1.0.3"
end

gem "thin"
gem "eventmachine"
gem "rack-fiber_pool", :require => "rack/fiber_pool"
gem "em-synchrony", :git => "git://github.com/igrigorik/em-synchrony.git", :require => "em-synchrony/em-http"
gem "em-http-request", :git => "git://github.com/igrigorik/em-http-request.git", :require => "em-http"
gem "addressable", :require => "addressable/uri"

gem "hiredis", "~> 0.3.1"
gem "redis", "~> 2.2.0", :require => ["redis/connection/synchrony", "redis"]

group :test, :development do
  gem "rspec-rails", "~> 2.6"
end
