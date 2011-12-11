module Relations
  extend ActiveModel::Naming

  attr_reader :user
  attr_reader :category

  class UserCategory
    def initialize user,category
      @user = user
      @category = category
    end

    def save
      Either.pure(->a,b{persist.(namespace(a),b)}).
        ap(validate_non_empty.(@user).bind(validate_hex)).
        ap(validate_non_empty.(@category).bind(validate_hex)).
        fmap ->_ {self}
    end

    private
    include Oregano::Redis
    include Oregano::Redis::Namespaces::UserCategories
    include Oregano::Redis::Persistables::Set
    include HexValidator
    include NonEmptyValidator
  end
end
