module LocalBitcoins
  module Escrows
    # Get a list of the token owner's releaseable escrows 
    #
    def escrows
      oauth_request(:get, '/api/escrows/')
    end

    # Release an escrow
    #
    def escrow_release(id)
      oauth_request(:post, "/api/escrow-release/#{id}/")
    end
  end
end
