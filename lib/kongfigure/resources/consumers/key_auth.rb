module Kongfigure::Resources::Consumers
  class KeyAuth < ::Kongfigure::Resources::Base

    attr_accessor :key

    def self.build(hash)
      key_auth     = new(hash["id"])
      key_auth.key = hash["key"]
      key_auth
    end

    def api_attributes
      {
        "key" => key
      }
    end
  end
end
