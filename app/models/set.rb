class Set
  attr_reader :name

  def initialize name
    @name = name
  end

  def save
    if REDIS.sadd(KEYSPACE, @name) then Just.new @name
    else Nothing.new end
  end

  def self.all
    REDIS.smembers KEYSPACE
  end

  private
  REDIS = Oregano::Redis.acquire
  KEYSPACE = "sets"
end
