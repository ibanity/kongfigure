module Kongfigure::Services
  class Consumer < Base
    def create_dependencies(http_client, resource, related_resource)
      super(http_client, resource, related_resource)
      create_key_auths(http_client, resource, related_resource)
      create_acls(http_client, resource, related_resource)
    end

    def update_dependencies(http_client, resource, related_resource)
      super(http_client, resource, related_resource)
      create_key_auths(http_client, resource, related_resource)
      create_acls(http_client, resource, related_resource)
    end

    def cleanup_dependencies(http_client, resource, related_resource)
      super(http_client, resource, related_resource)
      cleanup_key_auths(http_client, resource, related_resource)
      cleanup_acls(http_client, resource, related_resource)
    end

    def need_update_dependencies?(resource, related_resource)
      super(resource, related_resource) &&
        resource && (resource.acls != related_resource.acls || resource.key_auths != related_resource.key_auths)
    end

    private

    def create_acls(http_client, resource, related_resource)
      resource.acls.each do |acl|
        unless related_resource.has_acl?(acl)
          http_client.post("#{resource_name}/#{related_resource.identifier}/acls", acl.api_attributes.to_json)
        end
      end
    end

    def create_key_auths(http_client, resource, related_resource)
      resource.key_auths.each do |key_auth|
        unless related_resource.has_key_auth?(key_auth)
          http_client.post("#{resource_name}/#{related_resource.identifier}/key-auth", key_auth.api_attributes.to_json)
        end
      end
    end

    def cleanup_key_auths(http_client, local_resource, remote_resource)
      remote_resource.key_auths.each do |remote_resource_key_auth|
        unless local_resource.has_key_auth?(remote_resource_key_auth)
          http_client.delete("#{resource_name}/#{remote_resource.identifier}/key-auth/#{remote_resource_key_auth.id}")
        end
      end
    end

    def cleanup_acls(http_client, local_resource, remote_resource)
      remote_resource.acls.each do |remote_resource_acl|
        unless local_resource.has_acl?(remote_resource_acl)
          http_client.delete("#{resource_name}/#{remote_resource.identifier}/acls/#{remote_resource_acl.id}")
        end
      end
    end
  end
end
