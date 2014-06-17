module LocalBitcoins
  module Wallet
    # Gets information about the token owner's wallet balance
    def wallet
      data = oauth_request(:get, '/api/wallet/')
      Hashie::Mash.new(data['data'])
    end

    def wallet_balance
      wallet.except(:received_transactions_30d, :receiving_address_count, :sent_transactions_30d)
    end

    def wallet_send(address, amount)
      oauth_request(:post, '/api/wallet-send/', {:address=>address, :amount=>amount})
    end

    def wallet_send_pin(address, amount, pin)
      if valid_pin(pin)
        oauth_request(:post, '/api/wallet-send/', {:address=>address, :amount=>amount, :pin=>pin})
      else
        false
      end
    end

    def valid_pin(pin)
      oauth_request(:post, '/api/pincode/', {:pincode=>pin})['data']['pincode_ok']
    end

    def wallet_addr
      oauth_request(:post, '/api/wallet-addr/')
    end
  end
end
