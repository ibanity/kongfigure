module Kongfigure::Resources
  class Route < Base
    attr_accessor :name, :protocols, :methods, :hosts, :paths, :regex_priority, :strip_path, :preserve_host, :snis,
                  :sources, :destinations, :service

    def self.build(hash)
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
      route.plugins        = Kongfigure::Resources::Plugin.build_all(hash["plugins"] || [])
      route
    end

    def identifier
      name
    end

    def api_attributes
      {
        "name"           => name,
        "protocols"      => protocols,
        "methods"        => methods,
        "paths"          => paths,
        "regex_priority" => regex_priority,
        "strip_path"     => strip_path,
        "preserve_host"  => preserve_host,
        "sources"        => sources,
        "service"        => service,
        "url"            => url
      }.compact
    end
  end
end
