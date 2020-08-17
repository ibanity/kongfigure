module Kongfigure::Synchronizers
  class Service < Base

    def resource_module
      Kongfigure::Resources::Service
    end

    def resource_api_name
      "services"
    end

    def synchronize_routes(resource)
      routes_synchronizer = Kongfigure::Synchronizers::Route.new(@http_client, resource.routes, resource)
      routes_synchronizer.synchronize_all
    end

    def synchronize(resource)
      synchronize_resource(resource)
      synchronize_routes(resource)
      synchronize_plugins(resource)
    end
  end
end
