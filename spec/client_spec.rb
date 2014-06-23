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
      expect(escrows).to be_a Hashie::Mash
      expect(escrows.escrow_list[0].data.buyer_username).to eq "alice"
      expect(escrows.escrow_list[0].data.reference_code).to eq "123"
      expect(escrows.escrow_list[1].data.reference_code).to eq "456"
      expect(escrows.escrow_list[1].actions.release_url).to eq "/api/escrow_release/2/"
    end

    it 'returns a success message indicating the escrow has been released' do
      expect { client.escrow_release('12345') }.not_to raise_error
      message = client.escrow_release('12345')
      expect(message).to be_a Hashie::Mash
      expect(message.message).to eq "The escrow has been released successfully."

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
      expect(ads).to be_a Hashie::Mash
      expect(ads.ad_count).to eq 2
      expect(ads.ad_list[0].data.ad_id).to eq 12345
      expect(ads.ad_list[1].data.ad_id).to eq 123456
      expect(ads.ad_list[0].data.location_string).to eq "Puerto Vallarta, JAL, Mexico"
      expect(ads.ad_list[0].data.profile.username).to eq "Bob"
      expect(ads.ad_list[0].actions.contact_form).to eq  "https://localbitcoins.com/api/contact_create/12345/"
      expect(ads.ad_list[1].data.atm_model).to eq nil
    end

    it 'returns success message if the ad was updated' do
      expect { client.update_ad(12345,{:price_equation => "localbitcoins_sell_usd"}) }.not_to raise_error
      ad_update = client.update_ad(12345,{:price_equation => "localbitcoins_sell_usd"})
      expect(ad_update).to be_a Hashie::Mash
      expect(ad_update.message).to eq "Ad changed successfully!"
    end

    it 'returns success message if the ad was created' do
      expect { client.create_ad({}) }.not_to raise_error
      ad_create = client.create_ad({})
      expect(ad_create).to be_a Hashie::Mash
      expect(ad_create.message).to eq "Ad added successfully!"
    end

    it 'returns listing of ads from passed ids' do
      expect { client.ad_list("12345,123456") }.not_to raise_error
      ad_list = client.ad_list("12345,123456")
      expect(ad_list).to be_a Hashie::Mash
      expect(ad_list.count).to eq 2
      expect(ad_list.ad_list[0].data.ad_id).to eq 12345
      expect(ad_list.ad_list[1].data.ad_id).to eq 123456
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
      expect(wallet).to be_a Hashie::Mash
      expect(wallet.total.balance).to eq "0.05"
      expect(wallet.total.sendable).to eq "0.05"
      expect(wallet.receiving_address_list[0].address).to eq "15HfUY9LwwewaWwrKRXzE91tjDnHmye1hc"
    end

    it 'returns balance information for the token owners wallet' do
      expect { client.wallet_balance }.not_to raise_error
      wallet_balance = client.wallet_balance
      expect(wallet_balance).to be_a Hashie::Mash
      expect(wallet_balance.message).to eq "ok"
      expect(wallet_balance.total.balance).to eq "0.05"
      expect(wallet_balance.total.sendable).to eq "0.05"
      expect(wallet_balance.receiving_address_list[0].address).to eq "15HfUY9LwwewaWwrKRXzE91tjDnHmye1hc"
    end

    it 'returns confirmation message for sending btc' do
      expect { client.wallet_send("15HfUY9LwwewaWwrKRXzE91tjDnHmy2d2hc","0.001") }.not_to raise_error
      wallet_send = client.wallet_send("15HfUY9LwwewaWwrKRXzE91tjDnHmy2d2hc","0.001")
      expect(wallet_send).to be_a Hashie::Mash
      expect(wallet_send.message).to eq "Money is being sent"
    end

    it 'returns unused wallet address from token owners wallet' do
      expect { client.wallet_addr }.not_to raise_error
      wallet_address = client.wallet_addr
      expect(wallet_address.address).to eq "15HfUY9LwwewaWwrKRXzE91tjDnHmy2d2hc"
      expect(wallet_address.message).to eq "OK!"
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
      expect(contact_message).to be_a Hashie::Mash
      expect(contact_message.message).to eq "Message sent successfully."
    end

    it 'returns active contact list for token owner' do
      expect { client.active_contacts }.not_to raise_error
      active_contacts = client.active_contacts
      expect(active_contacts).to be_a Hashie::Mash
      expect(active_contacts.contact_count).to eq 3
      expect(active_contacts.contact_list[0].data.currency).to eq "MXN"
      expect(active_contacts.contact_list[1].data.currency).to eq "MXN"
      expect(active_contacts.contact_list[2].data.currency).to eq "USD"
      expect(active_contacts.contact_list[0].data.amount).to eq "1.00"
      expect(active_contacts.contact_list[1].data.amount).to eq "2.00"
      expect(active_contacts.contact_list[2].data.amount).to eq "0.10"
      expect(active_contacts.contact_list[0].data.advertisement.id).to eq 1234567
      expect(active_contacts.contact_list[1].data.advertisement.id).to eq 1234567
      expect(active_contacts.contact_list[2].data.advertisement.id).to eq 1234567
      expect(active_contacts.contact_list[0].data.advertisement.advertiser.username).to eq "Bob"
      expect(active_contacts.contact_list[1].data.advertisement.advertiser.username).to eq "Bob"
      expect(active_contacts.contact_list[2].data.advertisement.advertiser.username).to eq "Alice"
      expect(active_contacts.contact_list[0].data.is_selling).to eq true
      expect(active_contacts.contact_list[1].data.is_selling).to eq true
      expect(active_contacts.contact_list[2].data.is_selling).to eq false
      expect(active_contacts.contact_list[0].data.is_buying).to eq false
      expect(active_contacts.contact_list[1].data.is_buying).to eq false
      expect(active_contacts.contact_list[2].data.is_buying).to eq true
    end

    it 'returns active buyer contacts for token owner' do
      expect { client.active_contacts('buyer') }.not_to raise_error
      active_buyer_contacts = client.active_contacts('buyer')
      expect(active_buyer_contacts).to be_a Hashie::Mash
      expect(active_buyer_contacts.contact_count).to eq 1
      expect(active_buyer_contacts.contact_list[0].data.advertisement.id).to eq 123456
      expect(active_buyer_contacts.contact_list[0].data.advertisement.advertiser.username).to eq "Alice"
      expect(active_buyer_contacts.contact_list[0].data.contact_id).to eq 543210
    end

    it 'returns active seller contacts for token owner' do
      expect { client.active_contacts('seller') }.not_to raise_error
      active_seller_contacts = client.active_contacts('seller')
      expect(active_seller_contacts).to be_a Hashie::Mash
      expect(active_seller_contacts.contact_count).to eq 2
      expect(active_seller_contacts.contact_list[0].data.currency).to eq "MXN"
      expect(active_seller_contacts.contact_list[1].data.currency).to eq "MXN"
      expect(active_seller_contacts.contact_list[0].data.payment_completed_at).to eq nil
    end

    it 'returns list of released contacts' do
      expect { client.released_contacts }.not_to raise_error
      released_contacts = client.released_contacts
      expect(released_contacts).to be_a Hashie::Mash
      expect(released_contacts.contact_count).to eq 1
      expect(released_contacts.contact_list[0].data.advertisement.id).to eq 123456
      expect(released_contacts.contact_list[0].data.advertisement.advertiser.username).to eq "Alice"
      expect(released_contacts.contact_list[0].data.contact_id).to eq 543210
    end

    it 'returns list of canceled contacts' do
      expect { client.canceled_contacts }.not_to raise_error
      canceled_contacts = client.canceled_contacts
      expect(canceled_contacts).to be_a Hashie::Mash
      expect(canceled_contacts.contact_count).to eq 3
      expect(canceled_contacts.contact_list[0].data.advertisement.advertiser.username).to eq "Bob"
      expect(canceled_contacts.contact_list[2].data.advertisement.advertiser.username).to eq "Bob"
      expect(canceled_contacts.contact_list[0].data.canceled_at).to eq "2014-06-19T20:34:18+00:00"
      expect(canceled_contacts.contact_list[2].data.canceled_at).to eq  "2014-06-19T18:56:45+00:00"
      expect(canceled_contacts.contact_list[1].data.amount).to eq "108.46"
      expect(canceled_contacts.contact_list[2].data.amount).to eq "100.02"
    end

    it 'returns list of closed contacts' do
      expect { client.closed_contacts }.not_to raise_error
      closed_contacts = client.closed_contacts
      expect(closed_contacts).to be_a Hashie::Mash
      expect(closed_contacts.contact_count).to eq 3
      expect(closed_contacts.contact_list[0].data.advertisement.advertiser.username).to eq "Bob"
      expect(closed_contacts.contact_list[2].data.advertisement.advertiser.username).to eq "Bob"
      expect(closed_contacts.contact_list[0].data.canceled_at).to eq "2014-06-19T20:34:18+00:00"
      expect(closed_contacts.contact_list[2].data.canceled_at).to eq  "2014-06-19T18:56:45+00:00"
      expect(closed_contacts.contact_list[1].data.amount).to eq "108.46"
      expect(closed_contacts.contact_list[2].data.amount).to eq "100.02"
    end

    it 'returns list of messages for a contact' do
      expect { client.messages_from_contact('12345') }.not_to raise_error
      contact_messages = client.messages_from_contact('12345')
      expect(contact_messages).to be_a Hashie::Mash
      expect(contact_messages.message_count).to eq 3
      expect(contact_messages.message_list[0].msg).to eq "Message body"
      expect(contact_messages.message_list[1].msg).to eq "Text of the message."
      expect(contact_messages.message_list[0].sender.username).to eq "Bob"
      expect(contact_messages.message_list[2].sender.username).to eq "Alice"
    end

    it 'returns confirmation on cancellation of a contact' do
      expect { client.cancel_contact('12345') }.not_to raise_error
      cancel_contact = client.cancel_contact('12345')
      expect(cancel_contact).to be_a Hashie::Mash
      expect(cancel_contact.message).to eq "Contact canceled."
    end

    it 'returns confirmation of contact creation' do
      expect { client.create_contact('12345', '1000', 'Message body') }.not_to raise_error
      create_contact = client.create_contact('12345', '1000', 'Message body')
      expect(create_contact).to be_a Hashie::Mash
      expect(create_contact.data.message).to eq "OK!"
      expect(create_contact.actions.contact_url).to eq "https://localbitcoins.com/api/contact_info/123456/"
    end

    it 'returns specified contact' do
      expect { client.contact_info(12345) }.not_to raise_error
      contact_info = client.contact_info(12345)
      expect(contact_info.data.advertisement.advertiser.username).to eq "Bob"
      expect(contact_info.data.buyer.username).to eq "Alice"
      expect(contact_info.data.advertisement.id).to eq 1234567
      expect(contact_info.actions.messages_url).to eq "https://localbitcoins.com/api/contact_messages/12345/"
    end

    it 'returns list of contacts, from specified list' do
      expect { client.contacts_info('12345,54321') }.not_to raise_error
      contacts = client.contacts_info('12345,54321')
      expect(contacts).to be_a Hashie::Mash
      expect(contacts.contact_count).to eq 2
      expect(contacts.contact_list[0].data.advertisement.advertiser.username).to eq "Bob"
      expect(contacts.contact_list[1].data.advertisement.advertiser.username).to eq "Bob"
      expect(contacts.contact_list[0].data.buyer.username).to eq "Alice"
      expect(contacts.contact_list[1].data.buyer.username).to eq "Alice"
      expect(contacts.contact_list[0].actions.cancel_url).to eq "https://localbitcoins.com/api/contact_cancel/12345/"
    end

  end

  describe "#users" do
    before do
      stub_get('/api/myself/', 'myself.json')
      stub_get('/api/account_info/bob/', 'account_info.json')
      stub_post('/api/logout/', 'logout.json')
    end

    it 'returns user information on the token owner' do
      expect { client.myself }.not_to raise_error
      myself = client.myself
      expect(myself.username).to eq "alice"
      expect(myself.has_common_trades).to eq false
      expect(myself.trusted_count).to eq 4
    end

    it 'returns user information on user with specified username' do
      expect { client.account_info('bob') }.not_to raise_error
      account_info = client.account_info('bob')
      expect(account_info.username).to eq "bob"
      expect(account_info.trade_volume_text).to eq "Less than 25 BTC"
      expect(account_info.url).to eq "https://localbitcoins.com/p/bob/"
    end

    it 'immediately expires currently authorized access_token' do
      #expect { client.logout }.not_to raise_error

    end
  end

  describe "#markets" do
    before do
      stub_get_unauth('/bitcoinaverage/ticker-all-currencies/', 'ticker.json')
      stub_get_unauth('/bitcoincharts/USD/trades.json?since=170892', 'trades.json')
      stub_get_unauth('/bitcoincharts/USD/orderbook.json', 'orderbook.json')
    end

    it 'returns current bitcoin prices in all currencies' do
      expect { client.ticker }.not_to raise_error
      ticker = client.ticker
      expect(ticker.USD.volume_btc).to eq "701.42"
      expect(ticker.MXN.rates.last).to eq "8431.10"
      expect(ticker.PHP.avg_12h).to eq 24559.67
    end

    it 'returns last 500 trades in a specified currency since last_tid' do
      expect { client.trades('USD', '170892') }.not_to raise_error
      trades = client.trades('USD', '170892')
      expect(trades).to be_a Array
      expect(trades[0]['tid']).to eq 170892
      expect(trades[-1]['amount']).to eq "1.54970000"
    end

    it 'immediately expires currently authorized access_token' do
      expect { client.orderbook('USD') }.not_to raise_error
      orderbook = client.orderbook('USD')
      expect(orderbook).to be_a Hashie::Mash
      expect(orderbook.asks[0][1]).to eq "1190.53"
      expect(orderbook.bids[-1][0]).to eq "0.16"
    end
  end

  describe "#public" do
    before do
      stub_get_unauth('/buy-bitcoins-online/US/usa/moneygram/.json', 'online_buy_ads.json')
      stub_get_unauth('/sell-bitcoins-online/.json', 'online_sell_ads.json')
      stub_get_unauth('/api/payment_methods/us/', 'payment_methods.json')
      stub_get_unauth('/api/currencies/', 'currencies.json')
      stub_get_unauth('/buy-bitcoins-with-cash/214875/48453-mx/.json?lat=20&lon=-105', 'local_buy_ads.json')
      stub_get_unauth('/sell-bitcoins-with-cash/214875/48453-mx/.json?lat=20&lon=-105', 'local_sell_ads.json')
      stub_get_unauth('/api/places/?lat=35&lon=100', 'places.json')
    end

    it 'shows all online buy ads with given specifications' do
      expect { client.online_buy_ads_lookup({:countrycode => "US", :country_name => "usa", :payment_method => "moneygram"}) }.not_to raise_error
      ads = client.online_buy_ads_lookup({:countrycode => "US", :country_name => "usa", :payment_method => "moneygram"})
      expect(ads).to be_a Hashie::Mash
      expect(ads.data.ad_list[0][:data][:profile][:username]).to eq "btcusd"
      expect(ads.data.ad_count).to eq 15
    end

    it 'shows all online sell ads with given specifications' do
      expect { client.online_sell_ads_lookup }.not_to raise_error
      ads = client.online_sell_ads_lookup
      expect(ads).to be_a Hashie::Mash
      expect(ads.data.ad_list[0][:data][:created_at]).to eq "2013-09-22T08:50:04+00:00"
      expect(ads.data.ad_list[1][:actions][:public_view]).to eq "https://localbitcoins.com/ad/55455"
      expect(ads.pagination.next).to eq "https://localbitcoins.com/sell-bitcoins-online/.json?temp_price_usd__lt=571.35"
    end

    it 'shows all payment methods accepted in given countrycode' do
      expect { client.payment_methods('us') }.not_to raise_error
      payment = client.payment_methods('us')
      expect(payment).to be_a Hashie::Mash
      expect(payment[:methods].solidtrustpay.name).to eq "SolidTrustPay"
      expect(payment.method_count).to eq 22
    end

    it 'shows all currencies used by localbitcoins' do
      expect { client.currencies }.not_to raise_error
      currencies = client.currencies
      expect(currencies.currencies.EGP.name).to eq "Egyptian Pound"
      expect(currencies.currency_count).to eq 166
    end

    it 'shows all local buy ads with given specifications' do
      expect { client.local_buy_ad({:location_id=>214875, :location_slug=>"48453-MX", :lat=>20, :lon=>-105}) }.not_to raise_error
      ads = client.local_buy_ad({:location_id=>214875, :location_slug=>"48453-MX", :lat=>20, :lon=>-105})
      expect(ads.data.ad_list[0].data.profile.username).to eq "bob"
      expect(ads.data.ad_list[0].data.ad_id).to eq 123456
      expect(ads.data.ad_list[1].data.msg).to eq("Fell in a hole and found a secret and magical world! Bitcoins grow on trees down here ;)")
    end

    it 'shows all local sell ads with given specifications' do
      expect { client.local_sell_ad({:location_id=>214875, :location_slug=>"48453-MX", :lat=>20, :lon=>-105}) }.not_to raise_error
      ads = client.local_sell_ad({:location_id=>214875, :location_slug=>"48453-MX", :lat=>20, :lon=>-105})
      expect(ads.data.ad_list[0].data.profile.username).to eq "bobby"
      expect(ads.data.ad_list[0].data.ad_id).to eq 12345
      expect(ads.data.ad_list[1].data.msg).to eq "Hola, mundo!"
      expect(ads.data.ad_list[1].actions.public_view).to eq "https://localbitcoins.com/ad/67890"
    end

    it 'shows the location information associated with a given latitude and longitude' do
      expect { client.places({:lat=>35, :lon=>100}) }.not_to raise_error
      places = client.places({:lat=>35, :lon=>100})
      expect(places.places[0].location_string).to eq "Hainan, Qinghai, China"
      expect(places.places[0].lon).to eq 100.62
      expect(places.place_count).to eq 1
    end
  end
end