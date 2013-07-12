require 'rest-client'
require 'active_support/core_ext'
require 'json'
require 'hashie'
require 'oauth2'

module LocalBitcoins
  module Request
    API_URL = "https://www.localbitcoins.com"

    protected

    # Perform an OAuth API request. The client must be initialized 
    # with a valid OAuth access token. All API requests to 
    # LocalBitcoins currently require an access token.
    #
    # path   - Request path
    # params - Parameters hash
    #
    def oauth_request(http_method, path, params={})
      raise 'OAuth access token required!' unless @access_token
      params.merge!('Accept'=>'application/json')
      resp = @access_token.request(http_method, path, params)

      case resp
        when Net::HTTPUnauthorized
          raise LocalBitcoins::Unauthorized
        when Net::HTTPNotFound
          raise LocalBitcoins::NotFound
      end

      parse(resp)
    end

    def parse(resp)
      object = JSON.parse(resp.body)
      object
    end
  end
end
