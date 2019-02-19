require "colorize"

module Kongfigure::Services
  class Base

    def initialize(http_client)
      @http_client = http_client
    end

    def resource_name
      Dry::Inflector.new.pluralize(self.class.to_s.split("::").last.downcase.gsub("_", "-"))
    end

    def self.resource_name
      Dry::Inflector.new.pluralize(self.to_s.split("::").last.downcase.gsub("_", "-"))
    end

    def all
      module_name = Kongfigure::Resources.const_get(self.class.to_s.split("::").last)
      @http_client.get("#{resource_name}")["data"].map do |hash_resource|
        case resource_name
        when "consumers"
          hash_resource["acls"]      = @http_client.get("#{resource_name}/#{hash_resource['id']}/acls")["data"]
          hash_resource["key_auths"] = @http_client.get("#{resource_name}/#{hash_resource['id']}/key-auth")["data"]
          hash_resource["plugins"]   = @http_client.get("#{resource_name}/#{hash_resource['id']}/plugins")["data"]
        when "upstreams"
          hash_resource["targets"]   = @http_client.get("#{resource_name}/#{hash_resource['id']}/targets")["data"]
        when "services"
          hash_resource["plugins"]   = @http_client.get("#{resource_name}/#{hash_resource['id']}/plugins")["data"]
          hash_resource["routes"]    = @http_client.get("#{resource_name}/#{hash_resource['id']}/routes")["data"]
        end
        module_name.build(hash_resource)
      end
    end

    def create_or_update(http_client, resource, remote_resources)
      handle_api_errors do
        related_remote_resource = find_related_resource(resource, remote_resources)
        if related_remote_resource && need_update?(resource, related_remote_resource)
          puts "-> Update #{resource.class.name} (#{resource.identifier}).".colorize(:light_blue)
          update(http_client, resource, related_remote_resource)
        elsif related_remote_resource && need_update_dependencies?(resource, related_remote_resource)
          puts "-> Update dependencies #{resource.class.name} (#{resource.identifier}).".colorize(:light_blue)
          update_dependencies(http_client, resource, related_remote_resource)
        elsif related_remote_resource
          #noop
        else
          puts "-> Create #{resource.class.name} (#{resource.identifier}).".colorize(:green)
          create(http_client, resource, related_remote_resource)
        end
      end
    end

    def create(http_client, resource, _related_remote_resource)
      module_name = Kongfigure::Resources.const_get(self.class.to_s.split("::").last)
      data        = http_client.post("#{resource_name}", resource.api_attributes.to_json)
      create_dependencies(http_client, resource, module_name.build(data))
    end

    def update(http_client, resource, related_remote_resource)
      http_client.put("#{resource_name}/#{related_remote_resource.id}", resource.api_attributes.to_json) if need_update?(resource, related_remote_resource)
      update_dependencies(http_client, resource, related_remote_resource)
    end

    def cleanup(http_client, resource, related_remote_resource)
      puts "-> Cleanup #{related_remote_resource.class.name} (#{related_remote_resource.identifier}).".colorize(:magenta)
      http_client.delete("#{resource_name}/#{related_remote_resource.id}")
    end

    def cleanup_useless_resources(http_client, local_resources, remote_resources)
      useless_remote_resources = remote_resources.each do |remote_resource|
        related_local_resource = find_related_resource(remote_resource, local_resources)
        handle_api_errors do
          if need_cleanup_dependencies?(related_local_resource, remote_resource)
            cleanup_dependencies(http_client, related_local_resource, remote_resource)
          end
          unless related_local_resource
            cleanup(http_client, related_local_resource, remote_resource)
          end
        end
      end
    end

    def find_related_resource(target_resource, resources)
      resources.find do|resource|
        case target_resource.class
        when Kongfigure::Resources::Plugin
          resource.name     == target_resource.name &&
          resource.service  == target_resource.service &&
          resource.consumer == target_resource.consumer &&
          resource.route    == target_resource.route
        else
          resource.identifier == target_resource.identifier
        end
      end
    end

    def need_update?(resource, related_remote_resource)
      resource != related_remote_resource
    end

    def need_update_dependencies?(resource, related_remote_resource)
      need_update_plugins?(resource, related_remote_resource)
    end

    def need_cleanup_dependencies?(resource, related_remote_resource)
      resource.nil? || need_cleanup_plugins?(resource, related_remote_resource)
    end

    def has_plugins?(resource)
      resource.plugins && resource.plugins.size > 0
    end

    def update_dependencies(http_client, local_resource, related_remote_resource)
      create_or_update_plugins(http_client, local_resource, related_remote_resource)
    end

    def create_dependencies(http_client, local_resource, related_remote_resource)
      create_or_update_plugins(http_client, local_resource, related_remote_resource)
    end

    def cleanup_dependencies(http_client, local_resource, related_remote_resource)
      puts "-> Cleanup dependencies #{related_remote_resource.class.name} (#{related_remote_resource.identifier}).".colorize(:magenta)
      cleanup_plugins(http_client, local_resource, related_remote_resource)
    end

    def handle_api_errors(&block)
      begin
        yield
      rescue Kongfigure::Errors::BadRequest => e
        puts "<- Bad request: #{e.message}".colorize(:red)
      end
    end

    def need_update_plugins?(resource, related_remote_resource)
      resource.plugins.reject do |plugin|
        related_plugin = find_related_resource(plugin, related_remote_resource.plugins)
        related_plugin && plugin == related_plugin
      end.size != 0
    end

    def need_cleanup_plugins?(resource, related_remote_resource)
      resource.plugins.reject do |plugin|
        related_remote_plugin = find_related_resource(plugin, related_remote_resource.plugins)
        related_remote_plugin && plugin == related_remote_plugin
      end.size == 0 && resource.plugins.size < related_remote_resource.plugins.size
    end

    def create_or_update_plugins(http_client, local_resource, remote_resource)
      local_resource.plugins.each do |plugin|
        related_plugin = find_related_resource(plugin, remote_resource.plugins)
        if related_plugin
          http_client.patch("#{resource_name}/#{local_resource.identifier}/plugins/#{related_plugin.id}", plugin.api_attributes.to_json)
        else
          http_client.post("#{resource_name}/#{local_resource.identifier}/plugins", plugin.api_attributes.to_json)
        end
      end
    end

    def cleanup_plugins(http_client, local_resource, remote_resource)
      remote_resource.plugins.each do |plugin|
        if local_resource.nil? || find_related_resource(plugin, local_resource.plugins).nil?
          http_client.delete("#{resource_name}/#{remote_resource.identifier}/plugins/#{plugin.id}")
        end
      end
    end
  end
end
