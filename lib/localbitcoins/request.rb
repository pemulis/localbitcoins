require 'rest-client'
require 'active_support/core_ext'
require 'json'
require 'hashie'
require 'oauth2'

module LocalBitcoins
  module Request
    API_URL = "https://localbitcoins.com"

    protected

    # Perform an OAuth API request. The client must be initialized 
    # with a valid OAuth access token to make requests with this method
    #
    # path   - Request path
    # body -   Parameters for requests - GET and POST
    #
    def oauth_request(http_method, path, body={})
      raise 'OAuth access token required!' unless @access_token
      params = { :Accept =>'application/json', :access_token => @access_token.token }
      params.merge!(body) if http_method == :get
      resp = @access_token.request(http_method, path, :params => params, :body => body)
      case resp
        when Net::HTTPUnauthorized
          raise LocalBitcoins::Unauthorized
        when Net::HTTPNotFound
          raise LocalBitcoins::NotFound
      end
      hash = Hashie::Mash.new(JSON.parse(resp.body))
      raise Error.new(hash.error) if hash.error
      raise Error.new(hash.errors.join(',')) if hash.errors
      hash
    end
  end
end
