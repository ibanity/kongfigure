module Kongfigure::Resources::Consumers
  class ACL < ::Kongfigure::Resources::Base

    attr_accessor :group

    def self.build(hash)
      acl       = new(hash["id"])
      acl.group = hash["group"]
      acl
    end

    def plugin_allowed?
      false
    end

    def identifier
      group
    end

    def api_name
      "acls"
    end

    def api_attributes
      {
        "group" => group
      }.compact
    end
  end
end
