module LockableProxy
  private

  def sanitize_hash delegate,public_key
    JSON.parse(delegate.to_json(:except => :key)).merge(:key => @public_key)
  end

  def unique_id
    UniqueId.new.generate
  end

  def paired_id secret,public_key
    PairedId.new(secret,public_key).generate
  end

  UniqueId = Oregano::Redis::Generators::UniqueId
  PairedId = Oregano::Redis::Generators::PairedId
end
