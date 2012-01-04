module Oregano
  module Redis
    module Generators
      class UniqueId
        def generate
          Digest::SHA1.hexdigest SecureRandom.uuid
        end
      end

      class PairedId
        def initialize secret, key = UniqueId.new.generate
          @secret = secret
          @key = key
        end
        def generate
          Digest::SHA1.hexdigest @secret + @key
        end
      end

      class MappedId
        def initialize seed
          @seed = seed
        end
        def generate
          Digest::SHA1.hexdigest @seed
        end
      end
    end
  end
end
