module LocalBitcoins
  module Users
    def myself
      data = oauth_request(:get, '/api/myself/')
      Hashie::Mash.new(data['data'])
    end

    def account_info(username)
      data = oauth_request(:get, "/api/account_info/#{username}/")
      Hashie::Mash.new(data['data'])
    end

    def logout()
      oauth_request(:post, '/api/logout/')
    end
  end
end