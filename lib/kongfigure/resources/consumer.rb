module Kongfigure::Resources
  class Consumer < Base
    attr_accessor :username, :acls, :key_auths, :custom_id

    def self.build(hash)
      consumer           = new(hash["id"], hash["kongfigure_ignore_fields"])
      consumer.username  = hash["username"]
      consumer.custom_id = hash["custom_id"]
      consumer.acls      = Kongfigure::Resources::Consumers::ACL.build_all(hash["acls"] || [])
      consumer.plugins   = Kongfigure::Resources::Plugin.build_all(hash["plugins"] || [])
      consumer.key_auths = (hash["key_auths"] || []).map do |key_auth_hash|
        Kongfigure::Resources::Consumers::KeyAuth.build(key_auth_hash)
      end
      consumer
    end

    def identifier
      username
    end

    def api_attributes
      {
        "username"  =>  username,
        "custom_id" => custom_id
      }.compact
    end

    def has_key_auth?(key_auth)
      key_auths && key_auths.include?(key_auth)
    end

    def has_acl?(acl)
      acls && acls.include?(acl)
    end

    def to_s
      "#{username}"
    end
  end
end
