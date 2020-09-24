module Kongfigure::Synchronizers
  class Upstream < Base

    def resource_module
      Kongfigure::Resources::Upstream
    end

    def resource_api_name
      "upstreams"
    end

    def synchronize(resource)
      synchronize_resource(resource)
    end
  end
end
