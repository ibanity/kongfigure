module Kongfigure::Services
  class Upstream < Base
    def create_dependencies(http_client, resource, related_resource)
      super(http_client, resource, related_resource)
      create_targets(http_client, resource, related_resource)
    end

    def update_dependencies(http_client, resource, related_resource)
      super(http_client, resource, related_resource)
      create_targets(http_client, resource, related_resource)
    end

    def cleanup_dependencies(http_client, resource, related_resource)
      super(http_client, resource, related_resource)
      cleanup_targets(http_client, resource, related_resource)
    end

    def need_update_dependencies?(resource, related_resource)
      super(resource, related_resource) &&
        resource && (resource.targets != related_resource.targets)
    end

    private

    def create_targets(http_client, resource, related_resource)
      resource.targets.each do |target|
        unless related_resource.has_target?(target)
          http_client.post("#{resource_name}/#{related_resource.identifier}/targets", target.api_attributes.to_json)
        end
      end
    end

    def cleanup_targets(http_client, local_resource, remote_resource)
      remote_resource.targets.each do |remote_resource_target|
        if (local_resource.nil? || !local_resource.has_target?(remote_resource_target)) && remote_resource_target.weight > 0
          http_client.delete("#{resource_name}/#{remote_resource.identifier}/targets/#{remote_resource_target.id}")
        end
      end
    end
  end
end
