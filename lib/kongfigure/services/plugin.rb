module Kongfigure::Services
  class Plugin < Base

    def need_update_dependencies?(resource, related_resource)
      false
    end

    def need_cleanup_dependencies?(resource, related_resource)
      false
    end

    def cleanup(http_client, resource, related_resource)
      return unless related_resource.is_global?
      puts "-> Cleanup #{related_resource.class.name} (#{related_resource.identifier}).".colorize(:magenta)
      http_client.delete("#{resource_name}/#{related_resource.id}")
    end
  end
end
