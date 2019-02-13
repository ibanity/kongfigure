module Kongfigure
  class Parser

    def initialize(file, debug=false)
      @yaml_erb_configuration = File.read(file)
      @debug                  = debug
    end

    def parse!
      return @configuration unless @configuration.nil?
      @configuration = Kongfigure::Configuration.new
      puts "Parsing YAML configuration...".colorize(:color => :white, :background => :red)
      parsed_configuration = YAML.load(ERB.new(@yaml_erb_configuration).result)
      ap parsed_configuration if @debug
      parsed_configuration.each do |key, value|
        case key
        when "url"
          @configuration.url = value
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
