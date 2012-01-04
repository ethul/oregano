# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment',  __FILE__)

# Use the Rack::FiberPool with a configureable pool size, as in the example
# https://github.com/igrigorik/async-rails
use Rack::FiberPool, :size => 100

run Oregano::Application
