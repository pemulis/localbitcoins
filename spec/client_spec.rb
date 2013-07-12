require 'spec_helper'
require 'oauth2'

describe 'Client' do
  let(:client) { LocalBitcoins::Client.new(oauth_token: 'ACCESS_TOKEN') }

  describe "#escrows" do
    before do
      stub_get('/api/escrows/', 'escrows.json')
    end

    it 'returns escrows owner of the access token can release' do
      escrows = client.escrows
      escrows.should be_a Hashie::Mash
    end
  end
end
