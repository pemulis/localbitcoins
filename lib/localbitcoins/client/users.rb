module LocalBitcoins
  module Users
    def myself
      oauth_request(:get, '/api/myself/').data
    end

    def account_info(username)
      oauth_request(:get, "/api/account_info/#{username}/").data
    end

    # immediately expires the currently authorized access_token
    def logout
      oauth_request(:post, '/api/logout/')
    end
  end
end