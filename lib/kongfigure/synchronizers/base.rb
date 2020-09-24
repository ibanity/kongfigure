require "colorize"

module Kongfigure::Synchronizers
  class Base

    attr_reader :remote_resources, :resources, :parent_resource

    def initialize(http_client, resources, parent_resource=nil)
      @http_client      = http_client
      @parent_resource  = parent_resource
      @resources        = resources
      @remote_resources = load_all_remote_resources
    end

    def find(identifier)
      module_name = Kongfigure::Resources.const_get(self.class.to_s.split("::").last)
      module_name.build(@http_client.get("#{resource_api_name}/#{identifier}"))
    rescue Kongfigure::Errors::ResourceNotFound
      nil
    end

    def synchronize_resource(resource)
      remote_resource = find_related_remote_resource(resource)
      if remote_resource.nil?
        create(resource)
      elsif resource == remote_resource
        unchanged(resource)
        remote_resource.mark_as_unchanged
      else
        update(resource, remote_resource)
        remote_resource.mark_as_updated
      end
    end

    def synchronize_plugins(resource)
      plugins_synchronizer = Kongfigure::Synchronizers::Plugin.new(@http_client, resource.plugins, resource)
      plugins_synchronizer.synchronize_all
    end

    def synchronize(resource)
      synchronize_resource(resource)
      synchronize_plugins(resource)
    end

    def synchronize_all
      @resources.each do |resource|
        synchronize(resource)
      end
      @remote_resources.each do |remote_resource|
        cleanup(remote_resource) if remote_resource.has_to_be_deleted?
      end
    end

    def cleanup(remote_resource)
      puts "#{parent_resource.nil? ? '' : '  *'}#{'---'.colorize(:red)} #{remote_resource.display_name}"
      path = if parent_resource
        "#{parent_resource.api_name}/#{parent_resource.identifier}/#{resource_api_name}/#{remote_resource.identifier}"
      else
        "#{resource_api_name}/#{remote_resource.identifier}"
      end
      @http_client.delete(path)
    end

    def create(resource)
      puts "#{parent_resource.nil? ? '' : '  *'}#{'+++'.colorize(:green)} #{resource.display_name}"
      path = if parent_resource
        "#{parent_resource.api_name}/#{parent_resource.identifier}/#{resource_api_name}"
      else
        "#{resource_api_name}"
      end
      @http_client.post(path, resource.api_attributes.to_json)
    end

    def unchanged(resource)
      puts "#{parent_resource.nil? ? '' : '  *'}#{'==='.colorize(:blue)} #{resource.display_name}"
    end

    def update(resource, remote_resource)
      puts "#{'uuu'.colorize(:yellow)} #{resource.display_name}"
      path = if parent_resource
        "#{parent_resource.api_name}/#{parent_resource.identifier}/#{resource_api_name}/#{remote_resource.identifier}"
      else
        "#{resource_api_name}/#{remote_resource.identifier}"
      end
      @http_client.put(path, resource.api_attributes.to_json)
    end

    private
    def load_all_remote_resources
      if parent_resource.nil?
        @http_client.get("#{resource_api_name}")["data"].map do |hash_resource|
          resource_module.build(hash_resource)
        end
      else
        @http_client.get("#{parent_resource.api_name}/#{parent_resource.identifier}/#{resource_api_name}")["data"].map do |hash_resource|
          resource_module.build(hash_resource)
        end
      end
    end

    def find_related_remote_resource(resource)
      remote_resources.find do|remote_resource|
        resource.identifier == remote_resource.identifier
      end
    end
  end
end
