module Kongfigure::Synchronizers
  class Plugin < Base

    def load_all_remote_resources
      remote_resources = if parent_resource.nil?
        super.filter do |resource|
          resource.is_global?
        end
      else
        super
      end
    end

    def resource_module
      Kongfigure::Resources::Plugin
    end

    def resource_api_name
      "plugins"
    end

    def synchronize(resource)
      synchronize_resource(resource)
    end
  end
end
