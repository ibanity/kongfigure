module Kongfigure::Synchronizers
  class Route < Base

    def resource_module
      Kongfigure::Resources::Route
    end

    def resource_api_name
      "routes"
    end

    def synchronize(resource)
      synchronize_resource(resource)
    end
  end
end
