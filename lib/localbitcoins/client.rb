require 'localbitcoins/client'
require 'localbitcoins/client/escrows'
require 'localbitcoins/client/ads'

module LocalBitcoins
  class Client
    include LocalBitcoins::Escrows
    include LocalBitcoins::Ads

    attr_reader :oauth_token

    # Initialize a LocalBitcoins::Client instance
    #
    # All API calls to LocalBitcoins require an OAuth token, so you 
    # need to include one when you initialize the client.
    #
    # options[:oauth_token]
    #
    def initialize(options={})
      unless options.kind_of?(Hash)
        raise ArgumentError, "Options hash required."
      end

      @oauth_token = options[:oauth_token]
    end
  end
end
