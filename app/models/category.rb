class Category
  extend ActiveModel::Naming

  attr_reader :key
  attr_reader :items

  def initialize key,items = []
    @key = key
    @items = case items
      when Array then items
      else [items]
    end
  end

  def << item
    @items << item
  end

  def save
    validate_non_empty.(@key).
      bind(validate_hex).
      fmap(->k {namespace k}).
      bind(->k {
        format_non_empty_list.(@items).
          bind(validate_non_empty_list).
          bind(->vs {persist.(k,vs)}).
          fmap ->_ {self}
      })
  end

  private
  include Oregano::Redis
  include Oregano::Redis::Namespaces::Categories
  include Oregano::Redis::Persistables::Set
  include HexValidator
  include NonEmptyValidator
  include NonEmptyValidator
  include NonEmptyListValidator
  include NonEmptyListFormatter
end
