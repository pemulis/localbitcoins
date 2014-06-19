require 'spec_helper'
require 'oauth2'

describe 'Client' do
  let(:client) { LocalBitcoins::Client.new(
    client_id: 'CLIENT_ID',
    client_secret: 'CLIENT_SECRET',
    oauth_token: 'ACCESS_TOKEN'
  )}

  describe "#escrows" do
    before do
      stub_get('/api/escrows/','escrows.json')
      stub_post('/api/escrow_release/12345/', 'escrow_release.json')
    end

    it 'returns escrows, which the owner of the access token can release' do
      expect { client.escrows }.not_to raise_error

      escrows = client.escrows
      escrows.should be_a Hashie::Mash
      escrows.escrow_list[0].data.buyer_username.should eq "alice"
      escrows.escrow_list[0].data.reference_code.should eq "123"
      escrows.escrow_list[1].data.reference_code.should eq "456"
      escrows.escrow_list[1].actions.release_url.should eq "/api/escrow_release/2/"
    end

    it 'returns a success message indicating the escrow has been released' do
      expect { client.escrow_release('12345') }.not_to raise_error
      message = client.escrow_release('12345')
      message.should be_a Hashie::Mash
      message.data.message.should eq "The escrow has been released successfully."

    end
  end

end
