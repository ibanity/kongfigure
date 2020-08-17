module Kongfigure
  class Kong

    SYNCHRONIZER_MODULES = [
      Kongfigure::Synchronizers::Upstream,
      Kongfigure::Synchronizers::Service,
      Kongfigure::Synchronizers::Consumer,
      Kongfigure::Synchronizers::Plugin
    ]

    def initialize(parser, http_client)
      @parser        = parser
      @http_client   = http_client
      @synchronizers = {}
      @configuration = @parser.parse!
      load_synchronizers
      display_information
    end

    def apply!
      puts @configuration.to_s
      puts "Fetching actual configuration"
      @services
      puts "Applying configuration...".colorize(:color => :white, :background => :red)
      SYNCHRONIZER_MODULES.each do |synchronizer_module|
        apply_all(@synchronizers[synchronizer_module])
      end
      puts "Done.".colorize(:color => :white, :background => :red)
    end

    def apply_all(synchronizer)
      puts "<- Applying #{synchronizer.resource_api_name}..."
      synchronizer.synchronize_all
    end

    def display_information
      data = @http_client.get("/")
      puts "Kong information:".colorize(:color => :white, :background => :red)
      puts "* hostname: \t#{data['version']}"
      puts "* version: \t#{data['hostname']}"
      puts "* lua_version: \t#{data['lua_version']}"
    end

    private
    def load_synchronizers
      SYNCHRONIZER_MODULES.each do |synchronizer_module|
        resources = case synchronizer_module.to_s
        when Kongfigure::Synchronizers::Upstream.to_s
          @configuration.upstreams
        when Kongfigure::Synchronizers::Service.to_s
          @configuration.services
        when Kongfigure::Synchronizers::Consumer.to_s
          @configuration.consumers
        when Kongfigure::Synchronizers::Plugin.to_s
          @configuration.plugins
        end
        @synchronizers[synchronizer_module] = synchronizer_module.new(@http_client, resources || [])
      end
    end
  end
end
