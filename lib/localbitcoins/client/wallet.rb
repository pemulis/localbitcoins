module LocalBitcoins
  module Wallet
    # Gets information about the token owner's wallet balance
    def wallet
      request(:get, '/api/wallet/').data
    end

    def wallet_balance
      request(:get, '/api/wallet-balance/').data
    end

    def wallet_send(address, amount)
      request(:post, '/api/wallet-send/', {:address=>address, :amount=>amount}).data
    end

    def wallet_pin_send(address, amount, pin)
      request(:post, '/api/wallet-send/', {:address=>address, :amount=>amount, :pin=>pin}).data if valid_pin?(pin)
    end

    def valid_pin?(pin)
      request(:post, '/api/pincode/', {:pincode=>pin}).data.pincode_ok
    end

    def wallet_addr
      request(:post, '/api/wallet-addr/').data
    end
  end
end
