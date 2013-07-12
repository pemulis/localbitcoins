require 'localbitcoins/client'
require 'localbitcoins/client/escrows'
require 'localbitcoins/client/ads'

module LocalBitcoins
  class Client
    include LocalBitcoins::Request
    include LocalBitcoins::Escrows
    include LocalBitcoins::Ads

    attr_reader :oauth_client, :access_token

    # Initialize a LocalBitcoins::Client instance
    #
    # options[:client_id]
    # options[:client_secret]
    # options[:oauth_token]
    #
    def initialize(options={})
      unless options.kind_of?(Hash)
        raise ArgumentError, "Options hash required."
      end

      @oauth_client = OAuth2::Client.new(
        options[:client_id],
        options[:client_secret],
        authorize_url: "/oauth2/authorize",
        token_url: "/oauth2/access_token",
        site: "https://www.localbitcoins.com"
      )

      @access_token = OAuth2::AccessToken.new(
        oauth_client,
        options[:oauth_token]
      ) 
    end
  end
end
