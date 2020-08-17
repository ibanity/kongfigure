module Kongfigure::Synchronizers
  class Consumer < Base

    def synchronize(resource)
      super(resource)
      key_auths_synchronizer = Kongfigure::Synchronizers::Consumers::KeyAuth.new(@http_client, resource.key_auths, resource)
      key_auths_synchronizer.synchronize_all

      acls_synchronizer = Kongfigure::Synchronizers::Consumers::ACL.new(@http_client, resource.acls, resource)
      acls_synchronizer.synchronize_all
    end

    def resource_module
      Kongfigure::Resources::Consumer
    end

    def resource_api_name
      "consumers"
    end
  end
end

