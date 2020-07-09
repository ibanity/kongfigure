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
     puts "ALL"
     []
    end

    def synchronize(http_client, resource)
      puts "SYNC"
    end

    def cleanup(http_client, resource)
    end
  end
end
