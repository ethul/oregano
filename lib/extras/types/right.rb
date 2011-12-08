class Right < Either
  include Functors::Either::Right
  include Applicatives::Either::Right
  include Monads::Either::Right
  attr_reader :get
  def initialize a
    @get = a
  end
  def fold f,g
    g.(get)
  end
end
