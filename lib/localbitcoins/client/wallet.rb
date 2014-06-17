module LocalBitcoins
  module Wallet
    # Gets information about the token owner's wallet balance
    def wallet()
      data = oauth_request(:get, '/api/wallet/')
      Hashie::Mash.new(data)
    end

    def wallet_balance()
      oauth_request(:get, '/api/wallet-balance/')
    end

    def wallet_send(address, amount)
      oauth_request(:post, '/api/wallet-send/', {:address=>address, :amount=>amount})
    end

    def wallet_send_pin(address, amount, pin)
      oauth_request(:post, '/api/wallet-send/', {:address=>address, :amount=>amount, :pin=>pin})
    end

    def wallet_addr()
      oauth_request(:post, '/api/wallet-addr/')
    end

  end
end
