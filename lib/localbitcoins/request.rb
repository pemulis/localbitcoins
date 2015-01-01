require 'rest-client'
require 'active_support/core_ext'
require 'json'
require 'hashie'
require 'oauth2'
require 'openssl'
require 'date'
require 'uri'

module LocalBitcoins
  module Request
    API_URL = "https://localbitcoins.com"

    protected

    def request(*args)
      resp = @use_hmac ? self.hmac_request(*args) : self.oauth_request(*args)

      hash = Hashie::Mash.new(JSON.parse(resp.body))
      raise Error.new(hash.error) if hash.error
      raise Error.new(hash.errors.join(',')) if hash.errors
      hash
    end

    def hmac_request(http_method, path, body={})
      raise 'Client ID and secret required!' unless @client_id && @client_secret

      digest    = OpenSSL::Digest.new('sha256')
      nonce     = DateTime.now.strftime('%Q')
      params    = URI.encode_www_form(body)
      data      = [nonce, @client_id, path, params].join
      signature = OpenSSL::HMAC.hexdigest(digest, @client_secret, data)
      url       = "#{API_URL}#{path}"

      headers = {
        'Apiauth-Key' => @client_id,
        'Apiauth-Nonce' => nonce,
        'Apiauth-Signature' => signature,
      }

      # TODO(maros): Get the `RestClient::Request.execute` API to work.
      if http_method == :get
        RestClient.get("#{url}?#{params}", headers)
      else
        RestClient.post(url, params, headers)
      end
    end

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

      resp
    end
  end
end
