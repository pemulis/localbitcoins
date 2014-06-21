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
      expect { client.ad_list("12345,123456") }.not_to raise_error
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

  describe "#users" do
    before do
      stub_get('/api/myself/', 'myself.json')
      stub_get('/api/account_info/bob/', 'account_info.json')
      stub_post('/api/logout/', 'logout.json')
    end

    it 'returns user information on the token owner' do
      expect { client.myself }.not_to raise_error
      myself = client.myself
      myself.username.should eq "alice"
      myself.has_common_trades.should eq false
      myself.trusted_count.should eq 4
    end

    it 'returns user information on user with specified username' do
      expect { client.account_info('bob') }.not_to raise_error
      account_info = client.account_info('bob')
      account_info.username.should eq "bob"
      account_info.trade_volume_text.should eq "Less than 25 BTC"
      account_info.url.should eq "https://localbitcoins.com/p/bob/"
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
      ticker.USD.volume_btc.should eq "701.42"
      ticker.MXN.rates.last.should eq "8431.10"
      ticker.PHP.avg_12h.should eq 24559.67
    end

    it 'returns last 500 trades in a specified currency since last_tid' do
      expect { client.trades('USD', '170892') }.not_to raise_error
      trades = client.trades('USD', '170892')
      trades.should be_a Array
      trades[0]['tid'].should eq 170892
      trades[-1]['amount'].should eq "1.54970000"
    end

    it 'immediately expires currently authorized access_token' do
      expect { client.orderbook('USD') }.not_to raise_error
      orderbook = client.orderbook('USD')
      orderbook.should be_a Hashie::Mash
      orderbook.asks[0][1].should eq "1190.53"
      orderbook.bids[-1][0].should eq "0.16"
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
      ads.should be_a Hashie::Mash
      ads.data.ad_list[0][:data][:profile][:username].should eq "btcusd"
      ads.data.ad_count.should eq 15
    end

    it 'shows all online sell ads with given specifications' do
      expect { client.online_sell_ads_lookup }.not_to raise_error
      ads = client.online_sell_ads_lookup
      ads.should be_a Hashie::Mash
      ads.data.ad_list[0][:data][:created_at].should eq "2013-09-22T08:50:04+00:00"
      ads.data.ad_list[1][:actions][:public_view].should eq "https://localbitcoins.com/ad/55455"
      ads.pagination.next.should eq "https://localbitcoins.com/sell-bitcoins-online/.json?temp_price_usd__lt=571.35"
    end

    it 'shows all payment methods accepted in given countrycode' do
      expect { client.payment_methods('us') }.not_to raise_error
      payment = client.payment_methods('us')
      payment.should be_a Hashie::Mash
      payment[:methods].solidtrustpay.name.should eq "SolidTrustPay"
      payment.method_count.should eq 22
    end

    it 'shows all currencies used by localbitcoins' do
      expect { client.currencies }.not_to raise_error
      currencies = client.currencies
      currencies.currencies.EGP.name.should eq "Egyptian Pound"
      currencies.currency_count.should eq 166
    end

    it 'shows all local buy ads with given specifications' do
      expect { client.local_buy_ad({:location_id=>214875, :location_slug=>"48453-MX", :lat=>20, :lon=>-105}) }.not_to raise_error
      ads = client.local_buy_ad({:location_id=>214875, :location_slug=>"48453-MX", :lat=>20, :lon=>-105})
      ads.data.ad_list[0].data.profile.username.should eq "bob"
      ads.data.ad_list[0].data.ad_id.should eq 123456
      expect(ads.data.ad_list[1].data.msg).to eq("Fell in a hole and found a secret and magical world! Bitcoins grow on trees down here ;)")
      puts "Change everything to expect instead of should?"
    end

    it 'shows all local sell ads with given specifications' do
      expect { client.local_sell_ad({:location_id=>214875, :location_slug=>"48453-MX", :lat=>20, :lon=>-105}) }.not_to raise_error
      ads = client.local_sell_ad({:location_id=>214875, :location_slug=>"48453-MX", :lat=>20, :lon=>-105})
      ads.data.ad_list[0].data.profile.username.should eq "bobby"
      ads.data.ad_list[0].data.ad_id.should eq 12345
      ads.data.ad_list[1].data.msg.should eq "Hola, mundo!"
      ads.data.ad_list[1].actions.public_view.should eq "https://localbitcoins.com/ad/67890"
    end

    it 'shows the location information associated with a given latitude and longitude' do
      expect { client.places({:lat=>35, :lon=>100}) }.not_to raise_error
      places = client.places({:lat=>35, :lon=>100})
      places.places[0].location_string.should eq "Hainan, Qinghai, China"
      places.places[0].lon.should eq 100.62
      places.place_count.should eq 1
    end
  end


end
