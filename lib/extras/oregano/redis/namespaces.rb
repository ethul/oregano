module Oregano
  module Redis
    module Namespaces
      module Users
        def namespace key
          "users:#{key}"
        end
      end

      module Categories
        def namespace key
          "categories:#{key}"
        end
      end

      module Items
        def namespace key
          "items:#{key}"
        end
      end

      module UserCategories
        def namespace key
          "user_categories:#{key}"
        end
      end
    end
  end
end
