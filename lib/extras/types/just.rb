class Just < Maybe
  include Functors::Maybe::Just
  include Applicatives::Maybe::Just
  include Monads::Maybe::Just
  attr_reader :get
  def initialize a
    @get = a
  end
  def fold f,g
    g.(get)
  end
end
