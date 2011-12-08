class Left < Either
  include Functors::Either::Left
  include Applicatives::Either::Left
  include Monads::Either::Left
  attr_reader :get
  def initialize a
    @get = a
  end
  def fold f,g
    f.(get)
  end
end
