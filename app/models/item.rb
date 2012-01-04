class Item
  extend ActiveModel::Naming

  attr_reader :key
  attr_reader :value

  def initialize key,value
    @key = key
    @value = value
  end

  def save
    validate_non_empty.(@key).
      bind(validate_hex).
      fmap(->k {namespace k}).
      bind(->k {
        validate_non_empty.(@value).
          bind(format_utf8).
          bind(->v {persist.(k,v)}).
          fmap ->_ {self}
      })
  end

  private
  include Oregano::Redis
  include Oregano::Redis::Namespaces::Items
  include Oregano::Redis::Persistables::String
  include HexValidator
  include NonEmptyValidator
  include NonEmptyValidator
  include Utf8Formatter
end
