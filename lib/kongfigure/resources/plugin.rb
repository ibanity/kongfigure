module Kongfigure::Resources
  class Plugin < Base
    attr_accessor :name, :config, :enabled, :route, :service, :consumer, :run_on

    def self.build(hash)
      plugin          = new(hash["id"], hash["kongfigure_ignore_fields"])
      plugin.config   = hash["config"]
      plugin.name     = hash["name"]
      plugin.enabled  = hash["enabled"]
      plugin.route    = hash["route"]
      plugin.service  = hash["service"]
      plugin.consumer = hash["consumer"]
      plugin.run_on   = hash["run_on"]
      plugin
    end

    def identifier
      name
    end

    def api_attributes
      {
        "name"     =>     name,
        "config"   =>   config,
        "enabled"  =>  enabled,
        "route"    =>    route,
        "service"  =>  service,
        "consumer" => consumer,
        "run_on"   =>   run_on
      }.compact
    end

    def is_global?
      service.nil? && route.nil? && consumer.nil?
    end

    def to_s
      str = name
      if route
        str += " on route #{route}"
      elsif service
        str += " on service #{service}"
      elsif consumer
        str += " on consumer #{consumer}"
      else
        str += " attached globally"
      end
      str + (enabled ? " (enabled)" : " (disabled)")
    end
  end
end
