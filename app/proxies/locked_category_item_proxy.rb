class LockedCategoryItemProxy
  include LockableProxy

  def initialize attrs = {:secret => nil, :category => nil, :item => nil}
    attrs.symbolize_keys!
    @public_category_key = attrs[:category]
    @public_item_key = attrs[:item]
    @private_category_key = attrs[:private_category_key] || paired_id(attrs[:secret],@public_category_key)
    @private_item_key = attrs[:private_item_key] || paired_id(attrs[:secret],@public_item_key)
    @delegate = Relations::CategoryItem.new @private_category_key, @private_item_key
  end

  def save
    @delegate.save
  end

  def to_json options = {}
    Realtions::CategoryItem.new(@public_category_key,@public_item_key).to_json options
  end

  class << self
    def model_name
      Relations::CategoryItem.model_name
    end
  end
end
