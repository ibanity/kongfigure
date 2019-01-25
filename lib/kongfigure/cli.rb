require "optparse"

module Kongfigure
  class CLI
    attr_accessor :options

    def initialize
      @options       = {}
      @option_parser = OptionParser.new do |parser|
        parser.on("-f", "--file FILE", "Path to the Kong configuration file.") do |file|
          @options[:file] = file
        end
      end
    end

    def parse!
      @option_parser.parse!
      @options
    end
  end
end
