module Oregano
  module Redis
    @@host = "127.0.0.1"
    @@port = 6379
    @@database = 10
    @@connection = ::Redis.new :host => @@host, :port => @@port, :db => @@database
    def acquire
      @@connection
    end
  end
end
