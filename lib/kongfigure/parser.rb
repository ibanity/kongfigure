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
          @configuration.url = parse_url(value)
        when "urls"
          @configuration.url = parse_url(value)
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

    private
    def parse_url(urls)
      if urls.instance_of?(String)
        urls
      elsif urls.instance_of?(Hash)
        puts "Available URLs: "
        urls.keys.each_with_index do | key, index |
          puts "#{index}: #{key} -> #{urls[key]}"
        end
        puts "Enter the URL index:"
        index = STDIN.gets.chomp
        url   = urls[urls.keys[index.to_i]]
        raise "Wrong URL index: #{index}" if url.nil?
        url
      else
        raise "Can't parse URL: #{urls}."
      end
    end
  end
end
