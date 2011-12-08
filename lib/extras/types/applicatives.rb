# pure :: a -> f a
# ap :: f (a -> b) -> f a -> f b
#
# we want to apply the (a -> b) to the functor f a so
# below we invoke fmap on fa passing it the (a -> b) that
# is inside the current object. we don't reverse the params
# here since we want to write the applicative with the
# function first this time like
# Just(->(a) {->(b) {}}).ap(Just(a)).ap(Just(b))
module Applicatives
  module Maybe
    module Class
      # pure :: a -> Maybe a
      def pure a
        ::Just.new a
      end
    end

    # ap :: Maybe (a -> b) -> Maybe a -> Maybe b

    module Nothing
      def ap f
        ::Nothing.new
      end
    end

    module Just
      def ap f
        f.fmap self.get
      end
    end
  end

  module Either
    module Class
      # pure :: a -> Either e a
      def pure a
        ::Right.new a
      end
    end

    # ap :: Either e (a -> b) -> Either e a -> Either e b

    module Left
      def ap f
        f.fold ->(e){
          if self.get.respond_to?("concat")
            ::Left.new(self.get.concat f.get)
          else
            ::Left.new self.get
          end
        }, ->(a){::Left.new self.get}
      end
    end

    module Right
      def ap f
        f.fmap self.get
      end
    end
  end
end
