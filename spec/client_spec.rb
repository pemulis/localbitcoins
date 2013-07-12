require 'spec_helper'
require 'oauth'

describe 'Client' do
  describe '#escrows' do
    let(:consumer) { OAuth::Consumer.new('CLIENT_ID', 'CLIENT_SECRET', site: 'https://www.localbitcoins.com') }
    let(:token)    { OAuth::AccessToken.new(consumer, 'ACCESS_TOKEN', 'ACCESS_SECRET') }

    before do
      stub_request(:get, "https://www.localbitcoins.com/oauth2/access_token").
        to_return(status: 200, body: fixture('oauth_response.json'), headers: {})
    end

    it 'returns escrows owner of the access token can release' do
      client = LocalBitcoins::Client.new(oauth_token: token)
      
      escrows = client.escrows

      escrows.should be_a Hashie::Mash
    end
  end
end
