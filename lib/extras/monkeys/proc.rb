# adapted from http://blog.moertel.com/articles/2006/04/07/composing-functions-in-ruby
class Proc
  def self.compose f,g
    ->*as {f.(g.(*as))}
  end

  def * g
    Proc.compose self,g
  end
end
