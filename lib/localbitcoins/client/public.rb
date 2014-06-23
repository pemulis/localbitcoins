require 'open-uri'
module LocalBitcoins
  module Public
    ROOT = 'https://localbitcoins.com'

    # Valid API endpoints include:
    # /buy-bitcoins-online/{countrycode:2}/{country_name}/{payment_method}/.json
    # /buy-bitcoins-online/{countrycode:2}/{country_name}/.json
    # /buy-bitcoins-online/{currency:3}/{payment_method}/.json
    # /buy-bitcoins-online/{currency:3}/.json
    # /buy-bitcoins-online/{payment_method}/.json
    # /buy-bitcoins-online/.json
    #
    # NOTE: countrycode must be 2 characters and currency must be 3 characters
    #
    def online_buy_ads_lookup(params={})
      params.each_key do |k|
          params[k]<<'/'
      end
      online_buy_ads_uri = open("#{ROOT}/buy-bitcoins-online/#{params[:countrycode]}#{params[:currency]}#{params[:country_name]}#{params[:payment_method]}.json")
      Hashie::Mash.new(JSON.parse(online_buy_ads_uri.read)) if online_buy_ads_uri.status.first=='200'
    end

    # NOTE: Same format as online_buy_ads_lookup, but buy is replaced with sell
    #
    def online_sell_ads_lookup(params={})
      params.each do |k,v|
          params[k]=v<<'/' unless v.nil?
      end
      online_sell_ads_uri = open("#{ROOT}/sell-bitcoins-online/#{params[:countrycode]}#{params[:currency]}#{params[:country_name]}#{params[:payment_method]}.json")
      Hashie::Mash.new(JSON.parse(online_sell_ads_uri.read)) if online_sell_ads_uri.status.first=='200'
    end

    def payment_methods(countrycode=nil)
      countrycode<<'/' unless countrycode.nil?
      payment_methods_uri = open("#{ROOT}/api/payment_methods/#{countrycode}")
      Hashie::Mash.new(JSON.parse(payment_methods_uri.read)).data if payment_methods_uri.status.first=='200'
    end

    def currencies
      currencies_uri = open("#{ROOT}/api/currencies/")
      Hashie::Mash.new(JSON.parse(currencies_uri.read)).data if currencies_uri.status.first=='200'
    end

    # - Required fields -
    # location_id               - id for location found using places method
    # location_slug             - slug name for location found using places method
    #
    # - Optional fields -
    # lat                       - latitude of location [float]
    # lon                       - longitude of location [float]
    #
    def local_buy_ad(params)
      local_buy_ad_uri = open("#{ROOT}/buy-bitcoins-with-cash/#{params[:location_id]}/#{params[:location_slug].downcase}/.json?lat=#{params[:lat]}&lon=#{params[:lon]}")
      Hashie::Mash.new(JSON.parse(local_buy_ad_uri.read)) if local_buy_ad_uri.status.first=='200'
    end

    # NOTE: Same format as local_buy_ad, but buy is replaced with sell
    #
    def local_sell_ad(params={})
      local_sell_ad_uri = open("#{ROOT}/sell-bitcoins-with-cash/#{params[:location_id]}/#{params[:location_slug].downcase}/.json?lat=#{params[:lat]}&lon=#{params[:lon]}")
      Hashie::Mash.new(JSON.parse(local_sell_ad_uri.read)) if local_sell_ad_uri.status.first=='200'
    end

    # - Required fields -
    # lat                       - latitude of location [float]
    # lon                       - longitude of location [float]
    #
    # - Optional fields -
    # countrycode               - 2 letter countrycode
    # location_string           - location name in string form
    #
    def places(params={})
      places_uri = open("#{ROOT}/api/places/?#{params.to_query}")
      Hashie::Mash.new(JSON.parse(places_uri.read)).data if places_uri.status.first=='200'
    end
  end
end