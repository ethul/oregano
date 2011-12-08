class Nothing < Maybe
  include Functors::Maybe::Nothing
  include Applicatives::Maybe::Nothing
  include Monads::Maybe::Nothing
  def fold f,g
    f.()
  end
end
