class LockedItemProxy
  include LockableProxy

  def initialize attrs = {:secret => nil, :value => nil}
    attrs.symbolize_keys!
    @public_key = attrs[:public_key] || unique_id
    @private_key = attrs[:private_key] || paired_id(attrs[:secret],@public_key)
    @delegate = Item.new @private_key,attrs[:value]
  end

  def save
    @delegate.save.fmap ->_ {self}
  end

  def to_json options = {}
    sanitize_hash(@delegate,@public_key).to_json options
  end

  class << self
    def model_name
      Item.model_name
    end
  end
end
