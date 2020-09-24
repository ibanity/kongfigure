module Kongfigure::Synchronizers::Consumers
  class KeyAuth < Kongfigure::Synchronizers::Base

    def resource_module
      Kongfigure::Resources::Consumers::KeyAuth
    end

    def resource_api_name
      "key-auth"
    end

    def synchronize(resource)
      synchronize_resource(resource)
    end
  end
end
