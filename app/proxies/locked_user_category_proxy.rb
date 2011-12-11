class LockedUserCategoryProxy
  include LockableProxy

  def initialize attrs = {:secret => nil, :user => nil, :category => nil}
    attrs.symbolize_keys!
    @public_user_key = attrs[:user]
    @public_category_key = attrs[:category]
    @private_user_key = attrs[:private_user_key] || paired_id(attrs[:secret],@public_user_key)
    @private_category_key = attrs[:private_category_key] || paired_id(attrs[:secret],@public_category_key)
    @delegate = Relations::UserCategory.new @private_user_key, @private_category_key
  end

  def save
    @delegate.save
  end

  def to_json options = {}
    Relations::UserCategory.new(@public_user_key, @public_category_key).to_json options
  end

  class << self
    def model_name
      Relations::UserCategory.model_name
    end
  end
end
