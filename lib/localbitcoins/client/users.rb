module LocalBitcoins
  module Users
    def myself
      request(:get, '/api/myself/').data
    end

    def account_info(username)
      request(:get, "/api/account_info/#{username}/").data
    end

    # immediately expires the currently authorized access_token
    def logout
      request(:post, '/api/logout/')
    end
  end
end