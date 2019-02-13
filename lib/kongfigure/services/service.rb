module Kongfigure::Services
  class Service < Base
    def create_dependencies(http_client, resource, related_resource)
      super(http_client, resource, related_resource)
      create_routes(http_client, resource, related_resource)
    end

    def update_dependencies(http_client, resource, related_resource)
      super(http_client, resource, related_resource)
      create_routes(http_client, resource, related_resource)
    end

    def cleanup_dependencies(http_client, resource, related_resource)
      super(http_client, resource, related_resource)
      cleanup_routes(http_client, resource, related_resource)
    end

    def need_cleanup_dependencies?(resource, related_resource)
      super(resource, related_resource) || resource.nil? || resource.routes != related_resource.routes
    end

    def need_update_dependencies?(resource, related_resource)
      super(resource, related_resource) || (resource && (resource.routes != related_resource.routes))
    end

    private

    def create_routes(http_client, resource, related_resource)
      resource.routes.each do |route|
        unless related_resource.has_route?(route)
          http_client.post("#{resource_name}/#{related_resource.identifier}/routes", route.api_attributes.to_json)
        end
      end
    end

    def cleanup_routes(http_client, local_resource, remote_resource)
      # cleanup duplicated routes
      duplicated_routes = remote_resource.routes.select do |route|
        remote_resource.routes.count(route) > 1
      end.uniq
      duplicated_routes.each do |duplicated_route|
        http_client.delete("routes/#{duplicated_route.id}")
        remote_resource.routes.delete(duplicated_route)
      end
      # cleanup useless routes
      remote_resource.routes.each do |remote_resource_route|
        if local_resource.nil? || !local_resource.has_route?(remote_resource_route)
          http_client.delete("routes/#{remote_resource_route.id}")
        end
      end
    end
  end
end
