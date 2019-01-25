require "yaml"

module Kongfigure
  class Parser

    def initialize(file)
      @yaml_configuration = File.read(file)
      @configuration      = Kongfigure::Configuration.new
    end

    def parse!
      puts "Parsing YAML configuration...".colorize(:color => :white, :background => :red)
      YAML.load(@yaml_configuration).each do |key, value|
        case key
        when "host"
          @configuration.host = value
        when "services"
          @configuration.add_services(value || [])
        when "consumers"
           @configuration.add_consumers(value || [])
        when "plugins"
           @configuration.add_plugins(value || [])
        when "upstreams"
           @configuration.add_upstreams(value || [])
        else
          raise "Invalid configuration key: #{key}."
        end
      end
      @configuration
    end
  end
end
