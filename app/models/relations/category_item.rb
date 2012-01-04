module Relations
  class CategoryItem
    extend ActiveModel::Naming

    attr_reader :category
    attr_reader :item

    def initialize category,item
      @category = category
      @item = item
    end

    def save
      Either.pure(->a,b{persist.(namespace(a),b)}).
        ap(validate_hex.(@category)).
        ap(validate_hex.(@item)).
        fmap ->_ {self}
    end

    private
    include Oregano::Redis
    include Oregano::Redis::Namespaces::Categories
    include Oregano::Redis::Persistables::Set
    include HexValidator
  end
end
