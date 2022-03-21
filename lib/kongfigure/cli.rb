require "optparse"

module Kongfigure
  class CLI
    attr_accessor :options

    def initialize
      @options       = {
        debug: false
      }
      @option_parser = OptionParser.new do |parser|
        parser.on("-f", "--file FILE", "Path to the Kongfigure configuration file.") do |file|
          @options[:file] = file
        end
        parser.on("-u", "--url URL", "Url to the kong admin API.") do |url|
          @options[:url] = url
        end
        parser.on("-d", "--debug", "Debug mode.") do
          @options[:debug] = true
        end
        parser.on("-v", "--version", "Display version and exit.") do
          puts "Kongfigure version: #{Kongfigure::VERSION}"
          exit 0
        end
      end
    end

    def parse!(args)
      @option_parser.parse!(args)
      @options
    end
  end
end
