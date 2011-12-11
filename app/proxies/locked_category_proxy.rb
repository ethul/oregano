class LockedCategoryProxy
  include LockableProxy

  def initialize attrs = {:secret => nil, :items => []}
    attrs.symbolize_keys!
    @public_key = attrs[:public_key] || unique_id
    @private_key = attrs[:private_key] || paired_id(attrs[:secret],@public_key)
    @delegate = Category.new @private_key,attrs[:items]
  end

  def << item
    @delegate << item
  end

  def save
    @delegate.save
  end

  def to_json options = {}
    sanitize_hash(@delegate,@public_key).to_json options
  end

  class << self
    def model_name
      Category.model_name
    end
  end
end
