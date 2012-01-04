module Oregano
  module Redis
    module Fetchables
      module Base
        def fetch
          ->key {
            begin
              result = typed_fetch key
              if result then Right.new result
              else Left.new :fetch_failure end
            rescue => e
              Left.new e
            end
          }
        end
      end
      module String
        include Base
        def typed_fetch key
          acquire.get key
        end
      end
    end
  end
end
