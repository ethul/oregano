class Entry
  attr_reader :set
  attr_reader :content

  def initialize set, content
    @set = set
    @content = content
  end

  def save
    if REDIS.sadd("#{KEYSPACE}:#{@set}", @content) then Just.new true
    else Nothing.new end
  end

  def self.for_set set
    REDIS.smembers "#{KEYSPACE}:#{set}"
  end

  private
  REDIS = Oregano::Redis.acquire
  KEYSPACE = "sets"
end
