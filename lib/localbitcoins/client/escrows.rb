module LocalBitcoins
  module Escrows
    # Get a list of the token owner's releaseable escrows 
    #
    def escrows
      data = oauth_request(:get, '/api/escrows/')
      Hashie::Mash.new(data)
    end

    # Release an escrow
    #
    # release_url => the url of the escrow you want to release, 
    #                probably found by running the `escrows`
    #                method above
    #
    def escrow_release(id)
      data = oauth_request(:post, "/api/escrow-release/#{id}/")
      data['data']['message']
    end
  end
end
