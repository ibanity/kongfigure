require "json"

module Kongfigure
  class HTTPClient

    HTTP_HEADERS = {
      accept: "application/json; charset=UTF-8",
      content_type: "application/json; charset=UTF-8",
      accept_encoding: "gzip"
    }

    def initialize
      @configuration = {
        ssl_ca_path: nil,
        verify_ssl:  OpenSSL::SSL::VERIFY_NONE,
        url:         "https://localhost:8445"
      }
      @inflector = Dry::Inflector.new
    end

    def post(path, payload)
      execute(request_options(:post, path, payload))
    end

    def put(path, payload)
      execute(request_options(:put, path, payload))
    end

    def patch(path, payload)
      execute(request_options(:patch, path, payload))
    end

    def get(path)
      execute(request_options(:get, path))
    end

    def delete(path)
      execute(request_options(:delete, path))
   end

    private

    def execute(options)
      RestClient::Request.execute(options) do |response, _request, _result|
        handle_response(response)
      end
    end

    def ssl_options
      {
       ssl_ca_file: @configuration[:ssl_ca_path],
       verify_ssl:  @configuration[:verify_ssl]
     }
    end

    def request_options(method, path, payload = nil)
      opts = {
        method: method,
        url: "#{@configuration[:url]}/#{path}",
        headers: HTTP_HEADERS,
      }

      opts.merge!(ssl_options) if @configuration[:url].include?("https://")
      opts.merge!(payload: payload) if payload

      opts
    end


    def handle_response(response)
      if response.code == 204
        nil
      elsif response.code.between?(200, 399)
        handle_success(response)
      elsif response.code == 400
        parsed_response = JSON.parse(response.body)
        raise Kongfigure::Errors::BadRequest, {
          name:   parsed_response["name"],
          fields: parsed_response["fields"]
        }
      elsif response.code == 404
        raise Kongfigure::Errors::ResourceNotFound
      elsif response.code == 409
        raise Kongfigure::Errors::ResourceConflict
      elsif response.code == 500
        raise Kongfigure::Errors::InternalServerError
      end
    end

    def handle_success(response)
      JSON.parse(response.body)
    end
  end
end
