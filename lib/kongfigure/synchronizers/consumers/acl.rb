module Kongfigure::Synchronizers::Consumers
  class ACL < Kongfigure::Synchronizers::Base

    def resource_module
      Kongfigure::Resources::Consumers::ACL
    end

    def resource_api_name
      "acls"
    end

    def synchronize(resource)
      synchronize_resource(resource)
    end
  end
end
