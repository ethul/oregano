module Oregano
  module Redis
    module Persistables
      module Base
        def persist
          ->key,value {
            begin
              result = typed_persist key,value
              if result then Right.new :persist_success
              else Left.new :persist_failure end
            rescue => e
              Left.new e
            end
          }
        end
      end

      module String
        include Persistables::Base
        private
        def typed_persist key,value
          acquire.set key,value
        end
      end

      module StringNx
        include Persistables::Base
        private
        def typed_persist key,value
          acquire.setnx key,value
        end
      end

      module Set
        include Persistables::Base
        private
        def typed_persist key,values
          acquire.sadd key,values
        end
      end
    end
  end
end
