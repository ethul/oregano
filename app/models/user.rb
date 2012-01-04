class User
  attr_reader :key
  attr_reader :value

  def initialize key,value = UniqueId.new.generate
    @key = key
    @value = value
  end

  def save
    validate_non_empty.(@key).
      fmap(->k {MappedId.new(k).generate}).
      fmap(->k {namespace k}).
      bind(->k {validate_hex.(@value).bind(->v {persist.(k,v)})}).
      fold map_failure, ->_ {Right.new self}
  end

  class << self
    def load key
      validate_non_empty.(key).
        fmap(->k {MappedId.new(k).generate}).
        bind(validate_hex).
        bind ->k {fetch.(namespace k).fmap ->value {User.new k,value}}
    end

    private
    include Oregano::Redis
    include Oregano::Redis::Namespaces::Users
    include Oregano::Redis::Fetchables::String
    include HexValidator
    include NonEmptyValidator
  end

  private
  include Oregano::Redis
  include Oregano::Redis::Namespaces::Users
  include Oregano::Redis::Persistables::StringNx
  include HexValidator
  include NonEmptyValidator
  
  def map_failure
    ->a {
      if a == :persist_failure then Right.new self
      else Left.new a end
    }
  end

  UniqueId = Oregano::Redis::Generators::UniqueId
  MappedId = Oregano::Redis::Generators::MappedId
end
