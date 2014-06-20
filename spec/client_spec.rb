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
      message.message.should eq "The escrow has been released successfully."

    end
  end

  describe "#ads" do
    before do
      stub_get('/api/ads/', 'ads.json')
      stub_post('/api/ad/12345/', 'ad_update.json')
      stub_get('/api/ad-get/12345/', 'ad_single.json')
      stub_post('/api/ad-create/', 'ad_create.json')
      stub_get('/api/ad-get/', 'ad_list.json',{:ads=>"12345,123456"})
    end

    it 'returns listing of the token owners ads' do
      expect { client.ads }.not_to raise_error
      ads = client.ads
      ads.should be_a Hashie::Mash
      ads.ad_count.should eq 2
      ads.ad_list[0].data.ad_id.should eq 12345
      ads.ad_list[1].data.ad_id.should eq 123456
      ads.ad_list[0].data.location_string.should eq "Puerto Vallarta, JAL, Mexico"
      ads.ad_list[0].data.profile.username.should eq "Bob"
      ads.ad_list[0].actions.contact_form.should eq  "https://localbitcoins.com/api/contact_create/12345/"
      ads.ad_list[1].data.atm_model.should eq nil
    end

    it 'returns success message if the ad was updated' do
      expect { client.update_ad(12345,{:price_equation => "localbitcoins_sell_usd"}) }.not_to raise_error
      ad_update = client.update_ad(12345,{:price_equation => "localbitcoins_sell_usd"})
      ad_update.should be_a Hashie::Mash
      ad_update.message.should eq "Ad changed successfully!"
    end

    it 'returns success message if the ad was created' do
      expect { client.create_ad({}) }.not_to raise_error
      ad_create = client.create_ad({})
      ad_create.should be_a Hashie::Mash
      ad_create.message.should eq "Ad added successfully!"
    end

    it 'returns listing of ads from passed ids' do
      expect{ client.ad_list("12345,123456") }.not_to raise_error
      ad_list = client.ad_list("12345,123456")
      ad_list.should be_a Hashie::Mash
      ad_list.count.should eq 2
      ad_list.ad_list[0].data.ad_id.should eq 12345
      ad_list.ad_list[1].data.ad_id.should eq 123456
    end
  end

  describe "#wallet" do
    before do
      stub_get('/api/wallet/', 'wallet.json')
      stub_get('/api/wallet-balance/', 'wallet_balance.json')
      stub_post('/api/wallet-send/', 'wallet_send.json')
      stub_post('/api/wallet-addr/', 'wallet_addr.json')
    end

    it 'returns information about the token owners wallet' do
      expect { client.wallet }.not_to raise_error
      wallet = client.wallet
      wallet.should be_a Hashie::Mash
      wallet.total.balance.should eq "0.05"
      wallet.total.sendable.should eq "0.05"
      wallet.receiving_address_list[0].address.should eq "15HfUY9LwwewaWwrKRXzE91tjDnHmye1hc"
    end

    it 'returns balance information for the token owners wallet' do
      expect { client.wallet_balance }.not_to raise_error
      wallet_balance = client.wallet_balance
      wallet_balance.should be_a Hashie::Mash
      wallet_balance.message.should eq "ok"
      wallet_balance.total.balance.should eq "0.05"
      wallet_balance.total.sendable.should eq "0.05"
      wallet_balance.receiving_address_list[0].address.should eq "15HfUY9LwwewaWwrKRXzE91tjDnHmye1hc"
    end

    it 'returns confirmation message for sending btc' do
      expect { client.wallet_send("15HfUY9LwwewaWwrKRXzE91tjDnHmy2d2hc","0.001") }.not_to raise_error
      wallet_send = client.wallet_send("15HfUY9LwwewaWwrKRXzE91tjDnHmy2d2hc","0.001")
      wallet_send.should be_a Hashie::Mash
      wallet_send.message.should eq "Money is being sent"
    end

    it 'returns unused wallet address from token owners wallet' do
      expect { client.wallet_addr }.not_to raise_error
      wallet_address = client.wallet_addr
      wallet_address.address.should eq "15HfUY9LwwewaWwrKRXzE91tjDnHmy2d2hc"
      wallet_address.message.should eq "OK!"
    end
  end

  describe "#contacts" do
    before do
      stub_post('/api/contact_message_post/12345/', 'contact_message.json')
      stub_get('/api/dashboard/', 'contacts_active.json')
      stub_get('/api/dashboard/buyer/', 'contacts_active_buyers.json')
      stub_get('/api/dashboard/seller/', 'contacts_active_sellers.json')
      stub_get('/api/dashboard/released/', 'contacts_released_contacts.json')
      stub_get('/api/dashboard/canceled/', 'contacts_canceled_contacts.json')
      stub_get('/api/dashboard/closed/', 'contacts_canceled_contacts.json')
      stub_get('/api/contact_messages/12345/', 'contacts_messages.json')
      stub_post('/api/contact_cancel/12345/','contacts_cancel.json')
      stub_post('/api/contact_create/12345/', 'contacts_create.json')
      stub_get('/api/contact_info/12345/', 'contacts_contact_info.json')
      stub_get('/api/contact_info/', 'contacts_contacts_info.json', {:contacts=>"12345,54321"})
    end

    it 'returns confirmation for sending a message' do
      expect { client.message_contact('12345', 'Text of the message.') }.not_to raise_error
      contact_message = client.message_contact('12345', 'Text of the message.')
      contact_message.should be_a Hashie::Mash
      contact_message.message.should eq "Message sent successfully."
    end

    it 'returns active contact list for token owner' do
      expect { client.active_contacts }.not_to raise_error
      active_contacts = client.active_contacts
      active_contacts.should be_a Hashie::Mash
      active_contacts.contact_count.should eq 3
      active_contacts.contact_list[0].data.currency.should eq "MXN"
      active_contacts.contact_list[1].data.currency.should eq "MXN"
      active_contacts.contact_list[2].data.currency.should eq "USD"
      active_contacts.contact_list[0].data.amount.should eq "1.00"
      active_contacts.contact_list[1].data.amount.should eq "2.00"
      active_contacts.contact_list[2].data.amount.should eq "0.10"
      active_contacts.contact_list[0].data.advertisement.id.should eq 1234567
      active_contacts.contact_list[1].data.advertisement.id.should eq 1234567
      active_contacts.contact_list[2].data.advertisement.id.should eq 1234567
      active_contacts.contact_list[0].data.advertisement.advertiser.username.should eq "Bob"
      active_contacts.contact_list[1].data.advertisement.advertiser.username.should eq "Bob"
      active_contacts.contact_list[2].data.advertisement.advertiser.username.should eq "Alice"
      active_contacts.contact_list[0].data.is_selling.should eq true
      active_contacts.contact_list[1].data.is_selling.should eq true
      active_contacts.contact_list[2].data.is_selling.should eq false
      active_contacts.contact_list[0].data.is_buying.should eq false
      active_contacts.contact_list[1].data.is_buying.should eq false
      active_contacts.contact_list[2].data.is_buying.should eq true
    end

    it 'returns active buyer contacts for token owner' do
      expect { client.active_contacts('buyer') }.not_to raise_error
      active_buyer_contacts = client.active_contacts('buyer')
      active_buyer_contacts.should be_a Hashie::Mash
      active_buyer_contacts.contact_count.should eq 1
      active_buyer_contacts.contact_list[0].data.advertisement.id.should eq 123456
      active_buyer_contacts.contact_list[0].data.advertisement.advertiser.username.should eq "Alice"
      active_buyer_contacts.contact_list[0].data.contact_id.should eq 543210
    end

    it 'returns active seller contacts for token owner' do
      expect { client.active_contacts('seller') }.not_to raise_error
      active_seller_contacts = client.active_contacts('seller')
      active_seller_contacts.should be_a Hashie::Mash
      active_seller_contacts.contact_count.should eq 2
      active_seller_contacts.contact_list[0].data.currency.should eq "MXN"
      active_seller_contacts.contact_list[1].data.currency.should eq "MXN"
      active_seller_contacts.contact_list[0].data.payment_completed_at.should eq nil
    end

    it 'returns list of released contacts' do
      expect { client.released_contacts }.not_to raise_error
      released_contacts = client.released_contacts
      released_contacts.should be_a Hashie::Mash
      released_contacts.contact_count.should eq 1
      released_contacts.contact_list[0].data.advertisement.id.should eq 123456
      released_contacts.contact_list[0].data.advertisement.advertiser.username.should eq "Alice"
      released_contacts.contact_list[0].data.contact_id.should eq 543210
    end

    it 'returns list of canceled contacts' do
      expect { client.canceled_contacts }.not_to raise_error
      canceled_contacts = client.canceled_contacts
      canceled_contacts.should be_a Hashie::Mash
      canceled_contacts.contact_count.should eq 3
      canceled_contacts.contact_list[0].data.advertisement.advertiser.username.should eq "Bob"
      canceled_contacts.contact_list[2].data.advertisement.advertiser.username.should eq "Bob"
      canceled_contacts.contact_list[0].data.canceled_at.should eq "2014-06-19T20:34:18+00:00"
      canceled_contacts.contact_list[2].data.canceled_at.should eq  "2014-06-19T18:56:45+00:00"
      canceled_contacts.contact_list[1].data.amount.should eq "108.46"
      canceled_contacts.contact_list[2].data.amount.should eq "100.02"
    end

    it 'returns list of closed contacts' do
      expect { client.closed_contacts }.not_to raise_error
      closed_contacts = client.closed_contacts
      closed_contacts.should be_a Hashie::Mash
      closed_contacts.contact_count.should eq 3
      closed_contacts.contact_list[0].data.advertisement.advertiser.username.should eq "Bob"
      closed_contacts.contact_list[2].data.advertisement.advertiser.username.should eq "Bob"
      closed_contacts.contact_list[0].data.canceled_at.should eq "2014-06-19T20:34:18+00:00"
      closed_contacts.contact_list[2].data.canceled_at.should eq  "2014-06-19T18:56:45+00:00"
      closed_contacts.contact_list[1].data.amount.should eq "108.46"
      closed_contacts.contact_list[2].data.amount.should eq "100.02"
    end

    it 'returns list of messages for a contact' do
      expect { client.messages_from_contact('12345') }.not_to raise_error
      contact_messages = client.messages_from_contact('12345')
      contact_messages.should be_a Hashie::Mash
      contact_messages.message_count.should eq 3
      contact_messages.message_list[0].msg.should eq "Message body"
      contact_messages.message_list[1].msg.should eq "Text of the message."
      contact_messages.message_list[0].sender.username.should eq "Bob"
      contact_messages.message_list[2].sender.username.should eq "Alice"
    end

    it 'returns confirmation on cancellation of a contact' do
      expect { client.cancel_contact('12345') }.not_to raise_error
      cancel_contact = client.cancel_contact('12345')
      cancel_contact.should be_a Hashie::Mash
      cancel_contact.message.should eq "Contact canceled."
    end

    it 'returns confirmation of contact creation' do
      expect { client.create_contact('12345', '1000', 'Message body') }.not_to raise_error
      create_contact = client.create_contact('12345', '1000', 'Message body')
      create_contact.should be_a Hashie::Mash
      create_contact.data.message.should eq "OK!"
      create_contact.actions.contact_url.should eq "https://localbitcoins.com/api/contact_info/123456/"
    end

    it 'returns specified contact' do
      expect { client.contact_info(12345) }.not_to raise_error
      contact_info = client.contact_info(12345)
      contact_info.data.advertisement.advertiser.username.should eq "Bob"
      contact_info.data.buyer.username.should eq "Alice"
      contact_info.data.advertisement.id.should eq 1234567
      contact_info.actions.messages_url.should eq "https://localbitcoins.com/api/contact_messages/12345/"
    end

    it 'returns list of contacts, from specified list' do
      expect { client.contacts_info('12345,54321') }.not_to raise_error
      contacts = client.contacts_info('12345,54321')
      contacts.should be_a Hashie::Mash
      contacts.contact_count.should eq 2
      contacts.contact_list[0].data.advertisement.advertiser.username.should eq "Bob"
      contacts.contact_list[1].data.advertisement.advertiser.username.should eq "Bob"
      contacts.contact_list[0].data.buyer.username.should eq "Alice"
      contacts.contact_list[1].data.buyer.username.should eq "Alice"
      contacts.contact_list[0].actions.cancel_url.should eq "https://localbitcoins.com/api/contact_cancel/12345/"
    end

  end
end
