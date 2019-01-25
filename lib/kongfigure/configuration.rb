require "optparse"
require "pp"
require "awesome_print"

module Kongfigure
  class Configuration

    attr_accessor :host, :services, :consumers, :plugins, :upstreams

    def initialize
      @host      = nil
      @services  = []
      @consumers = []
      @plugins   = []
      @upstreams = []
    end

    def add_services(yaml_services)
      yaml_services.each do |yaml_service|
        @services.push(Kongfigure::Resources::Service.build(yaml_service))
      end
    end

    def add_consumers(yaml_consumers)
      yaml_consumers.each do |yaml_consumer|
        @consumers.push(Kongfigure::Resources::Consumer.build(yaml_consumer))
      end
    end

    def add_plugins(yaml_plugins)
      yaml_plugins.each do |yaml_plugin|
        @plugins.push(Kongfigure::Resources::Plugin.build(yaml_plugin))
      end
    end

    def add_upstreams(yaml_upstreams)
      yaml_upstreams.each do |yaml_upstream|
        @upstreams.push(Kongfigure::Resources::Upstream.build(yaml_upstream))
      end
    end

    def to_s
      {
        services:  @services.map  do |service| service.to_s end,
        consumers: @consumers.map do |consumer| consumer.to_s end,
        plugins:   @plugins.map   do |plugin| plugin.to_s end,
        upstreams: @upstreams.map do |upstream| upstream.to_s end
      }.ai
    end
  end
end
