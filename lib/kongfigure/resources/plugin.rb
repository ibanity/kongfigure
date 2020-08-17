module Kongfigure::Resources
  class Plugin < Base
    attr_accessor :name, :config, :enabled, :route, :service, :consumer, :run_on, :id

    def self.build(hash)
      raise "Plugin ID is missing for #{hash.inspect}" if hash["id"].nil?
      plugin          = new(hash["id"], hash["kongfigure_ignore_fields"])
      plugin.id       = hash["id"]
      plugin.config   = hash["config"]
      plugin.name     = hash["name"]
      plugin.enabled  = hash["enabled"]
      plugin.route    = hash["route"]
      plugin.service  = hash["service"]
      plugin.consumer = hash["consumer"]
      plugin.run_on   = hash["run_on"]
      plugin
    end

    def plugin_allowed?
      false
    end

    def identifier
      id
    end

    def api_attributes
      {
        "id"       => id,
        "name"     => name,
        "config"   => config || {},
        "enabled"  => enabled,
        "route"    => route,
        "service"  => service,
        "consumer" => consumer,
        "run_on"   => run_on
      }.compact
    end

    def is_global?
      service.nil? && route.nil? && consumer.nil?
    end

    def display_name
      name + " (id: #{identifier})"
    end

    def api_name
      "plugins"
    end

    def to_s
      str = display_name
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
