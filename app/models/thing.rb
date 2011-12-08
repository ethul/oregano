class Thing
  attr_reader :list
  attr_reader :content

  def initialize list, content
    @list = list
    @content = content
  end

  def save
    if REDIS.sadd("#{KEYSPACE}:#{@list}", @content) then Just.new true
    else Nothing.new end
  end

  def self.for_list list
    REDIS.smembers "#{KEYSPACE}:#{list}"
  end

  private
  REDIS = Lot::Redis.acquire
  KEYSPACE = "lists"
end
