require_relative "kongfigure/version.rb"
require_relative "kongfigure/cli.rb"
require_relative "kongfigure/resources/base.rb"
require_relative "kongfigure/resources/consumers/acl.rb"
require_relative "kongfigure/resources/consumers/key_auth.rb"
require_relative "kongfigure/resources/consumer.rb"
require_relative "kongfigure/resources/plugin.rb"
require_relative "kongfigure/resources/route.rb"
require_relative "kongfigure/resources/service.rb"
require_relative "kongfigure/resources/target.rb"
require_relative "kongfigure/resources/upstream.rb"
require_relative "kongfigure/synchronizers/base.rb"
require_relative "kongfigure/synchronizers/consumer.rb"
require_relative "kongfigure/synchronizers/plugin.rb"
require_relative "kongfigure/synchronizers/route.rb"
require_relative "kongfigure/synchronizers/service.rb"
require_relative "kongfigure/synchronizers/upstream.rb"
require_relative "kongfigure/synchronizers/consumers/key_auth.rb"
require_relative "kongfigure/synchronizers/consumers/acl.rb"
require_relative "kongfigure/configuration.rb"
require_relative "kongfigure/parser.rb"
require_relative "kongfigure/http_client.rb"
require_relative "kongfigure/kong.rb"
require_relative "kongfigure/errors/resource_not_found.rb"
require_relative "kongfigure/errors/resource_conflict.rb"
require_relative "kongfigure/errors/bad_request.rb"
require_relative "kongfigure/errors/internal_server_error.rb"
require_relative "kongfigure/errors/invalid_configuration.rb"

require "rest-client"
require "logger"
require "yaml"
require "erb"
require "optparse"
require "pp"
require "awesome_print"
require "digest"
require "dry/inflector"

module Kongfigure
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.start(args)
    # CLI
    cli           = Kongfigure::CLI.new
    options       = cli.parse!(args)
    # Parser
    parser        = Kongfigure::Parser.new(options[:file], options[:debug])
    http_client   = Kongfigure::HTTPClient.new(parser, options[:url])
    kong          = Kongfigure::Kong.new(parser, http_client)
    kong.apply!
  end
end
