require "uri"
module Kongfigure::Resources
  class Service < Base
    attr_accessor :name, :retries, :protocol, :host, :port, :path, :connect_timeout,
                  :write_timeout, :read_timeout, :url, :routes

    def self.build(hash)
      service = new(hash["id"], hash["kongfigure_ignore_fields"])
      service.name            = hash["name"]
      service.retries         = hash["retries"]
      service.protocol        = hash["protocol"]
      service.host            = hash["host"]
      service.port            = hash["port"]
      service.path            = hash["path"]
      service.connect_timeout = hash["connect_timeout"]
      service.write_timeout   = hash["write_timeout"]
      service.read_timeout    = hash["read_timeout"]
      service.plugins         = Kongfigure::Resources::Plugin.build_all(hash["plugins"] || [])
      service.routes          = Kongfigure::Resources::Route.build_all(hash["routes"] || [])
      service.url             = hash["url"] || URI::Generic.build({
        scheme: hash["protocol"],
        host:   hash["host"],
        port:   hash["port"],
        path:   hash["path"]
      }).to_s
      service
    end

    def identifier
      name
    end

    def has_route?(other_route)
      routes && routes.find do |route|
        other_route == route
      end
    end

    def has_routes?(other_routes)
      other_routes.reject do |other_route|
        has_route?(other_route)
      end.size == 0
    end

    def api_attributes
      {
        "name"            => name,
        "retries"         => retries,
        "protocol"        => protocol,
        "host"            => host,
        "port"            => port,
        "path"            => path,
        "connect_timeout" => connect_timeout,
        "write_timeout"   => write_timeout,
        "read_timeout"    => read_timeout,
        "url"             => url
      }.compact
    end

    def to_s
      name
    end
  end
end
