require 'open-uri'
module LocalBitcoins
  module Public
    ROOT = 'https://localbitcoins.com'

    def online_buy_ads_lookup(params={})

      # Valid API endpoints include:
      # /buy-bitcoins-online/{countrycode:2}/{country_name}/{payment_method}/.json
      # /buy-bitcoins-online/{countrycode:2}/{country_name}/.json
      # /buy-bitcoins-online/{currency:3}/{payment_method}/.json
      # /buy-bitcoins-online/{currency:3}/.json
      # /buy-bitcoins-online/{payment_method}/.json
      # /buy-bitcoins-online/.json
      #
      # NOTE: countrycode must be 2 characters and currency must be 3 characters

      params.each |k,v|
          params[k]=v<<'/' unless v.nil?
      online_buy_ads_uri = open("#{ROOT}/buy-bitcoins-online/#{params[:countrycode]+params[:currency]+params[:country_name]+params[:payment_method]}.json")
      online_buy_ads_uri.read if online_buy_ads_uri.status.first=='200'
    end

    def online_sell_ads_lookup(params={})

      # /sell-bitcoins-online/{countrycode:2}/{country_name}/{payment_method}/.json
      # /sell-bitcoins-online/{countrycode:2}/{country_name}/.json
      # /sell-bitcoins-online/{currency:3}/{payment_method}/.json
      # /sell-bitcoins-online/{currency:3}/.json
      # /sell-bitcoins-online/{payment_method}/.json
      # /sell-bitcoins-online/.json
      #
      # NOTE: countrycode must be 2 characters and currency must be 3 characters

      params.each |k,v|
          params[k]=v<<'/' unless v.nil?
      online_sell_ads_uri = open("#{ROOT}/buy-bitcoins-online/#{params[:countrycode]+params[:currency]+params[:country_name]+params[:payment_method]}.json")
      online_sell_ads_uri.read if online_sell_ads_uri.status.first=='200'
    end

    def payment_methods(countrycode)
      countrycode<<'/' unless countrycode.nil?
      payment_methods_uri = open("#{ROOT}/api/payment_methods/#{countrycode}")
      payment_methods_uri.read if payment_methods_uri.status.first=='200'
    end

    def currencies
      currencies_uri = open("#{ROOT}/api/currencies/")
      currencies_uri.read if currencies_uri.status.first=='200'
    end

    def local_buy_ad(location_id, location_slug)
      local_buy_ad_uri = open("#{ROOT}/buy-bitcoins-with-cash/#{location_id}/#{location_slug}/.json")
      local_buy_ad_uri.read if local_buy_ad_uri.status.first=='200'
    end

    def local_sell_ad(location_id, location_slug)
      local_sell_ad_uri = open("#{ROOT}/sell-bitcoins-with-cash/#{location_id}/#{location_slug}/.json")
      local_sell_ad_uri.read if local_sell_ad_uri.status.first=='200'
    end

    def places(params={})
      encoded = URI.escape(params.collect{|k,v| "#{k}=#{v}"}.join('&'))
      places_uri = open("#{ROOT}/api/places/#{encoded}")
      places_uri.read if places_uri.status.first=='200'
    end

  end
end