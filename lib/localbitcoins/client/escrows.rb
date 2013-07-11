module LocalBitcoins
  module Escrows
    # Get a list of the token owner's releaseable escrows 
    #
    def escrows()
      data = oauth_request(:get, '/api/escrows')
      Hashie::Mash.new(data['escrow_list'])
    end

    # Release an escrow
    #
    # release_url => the url of the escrow you want to release, 
    #                probably found by running the `escrows`
    #                method above
    #
    def escrow_release(release_url)
      data = oauth_request(:post, release_url)
      data['data']['message']
    end
  end
end
