require "optparse"

module Kongfigure
  class CLI
    attr_accessor :options

    def initialize
      @options       = {}
      @option_parser = OptionParser.new do |parser|
        parser.on("-f", "--file FILE", "Path to the Kongfigure configuration file.") do |file|
          @options[:file] = file
        end
        parser.on("-u", "--url URL", "Url to the kong admin API.") do |url|
          @options[:url] = url
        end
      end
    end

    def parse!(args)
      @option_parser.parse!(args)
      @options
    end
  end
end
