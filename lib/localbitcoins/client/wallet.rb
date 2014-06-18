module LocalBitcoins
  module Wallet
    # Gets information about the token owner's wallet balance
    def wallet
      data = oauth_request(:get, '/api/wallet/')
      Hashie::Mash.new(data['data'])
    end

    def wallet_balance
      data = wallet.except(:received_transactions_30d, :receiving_address_count, :sent_transactions_30d)
      Hashie::Mash.new(data)
    end

    def wallet_send(address, amount)
      data = oauth_request(:post, '/api/wallet-send/', {:address=>address, :amount=>amount})
      Hashie::Mash.new(data)
    end

    def wallet_send_pin(address, amount, pin)
      if valid_pin(pin)
        data = oauth_request(:post, '/api/wallet-send/', {:address=>address, :amount=>amount, :pin=>pin})
        Hashie::Mash.new(data)
      else
        false
      end
    end

    def valid_pin(pin)
      data = oauth_request(:post, '/api/pincode/', {:pincode=>pin})['data']['pincode_ok']
      Hashie::Mash.new(data)
    end

    def wallet_addr
      data = oauth_request(:post, '/api/wallet-addr/')
      Hashie::Mash.new(data)
    end
  end
end
