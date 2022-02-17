module Kongfigure::Resources
  class Route < Base
    attr_accessor :name, :protocols, :methods, :hosts, :paths, :regex_priority, :strip_path, :preserve_host, :snis,
                  :sources, :destinations, :service

    def self.build(hash)
      raise "Route ID is missing for #{hash.inspect}" if hash["id"].nil?
      route                = new(hash["id"], hash["kongfigure_ignore_fields"])
      route.name           = hash["name"]
      route.protocols      = hash["protocols"]
      route.methods        = hash["methods"]
      route.paths          = hash["paths"]
      route.regex_priority = hash["regex_priority"]
      route.strip_path     = hash["strip_path"]
      route.preserve_host  = hash["snis"]
      route.sources        = hash["destinations"]
      route.service        = hash["service"]
      route.hosts          = hash["hosts"]
      route.headers        = hash["headers"]
      route.plugins        = Kongfigure::Resources::Plugin.build_all(hash["plugins"] || [])
      route
    end

    def identifier
      id
    end

    def api_name
      "routes"
    end

    def display_name
      if name.nil?
        "default route"
      else
        "route (name: #{name})"
      end
    end

    def api_attributes
      {
        "id"             => id,
        "name"           => name,
        "protocols"      => protocols,
        "methods"        => methods,
        "paths"          => paths,
        "hosts"          => hosts,
        "headers"        => headers,
        "regex_priority" => regex_priority,
        "strip_path"     => strip_path,
        "preserve_host"  => preserve_host,
        "sources"        => sources,
        "service"        => service
      }.compact
    end
  end
end
