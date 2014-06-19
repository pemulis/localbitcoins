module LocalBitcoins
  module Wallet
    # Gets information about the token owner's wallet balance
    def wallet
      oauth_request(:get, '/api/wallet/').data
    end

    def wallet_balance
      oauth_request(:get, '/api/wallet-balance/').data
    end

    def wallet_send(address, amount)
      oauth_request(:post, '/api/wallet-send/', {:address=>address, :amount=>amount}).data
    end

    def wallet_pin_send(address, amount, pin)
      oauth_request(:post, '/api/wallet-send/', {:address=>address, :amount=>amount, :pin=>pin}).data if valid_pin?(pin)
    end

    def valid_pin?(pin)
      oauth_request(:post, '/api/pincode/', {:pincode=>pin}).data.pincode_ok
    end

    def wallet_addr
      oauth_request(:post, '/api/wallet-addr/').data
    end
  end
end
