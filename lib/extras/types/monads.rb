# return :: a -> f a
# bind :: f a -> (a -> f b) -> f b
module Monads
  module Maybe
    module Class
      # return :: a -> Maybe a
      def return a
        ::Just.new a
      end
    end

    # bind :: Maybe a -> (a -> Maybe b) -> Maybe b
    module Nothing
      def bind f
        ::Nothing.new
      end
    end

    module Just
      def bind f
        f.curry.(get)
      end
    end
  end

  module Either
    module Class
      # return :: a -> Either e a
      def return a
        ::Right.new a
      end
    end

    # bind :: Either e a -> (a -> Either e b) -> Either e b
    module Left
      def bind f
        ::Left.new get
      end
    end

    module Right
      def bind f
        f.curry.(get)
      end
    end
  end
end
