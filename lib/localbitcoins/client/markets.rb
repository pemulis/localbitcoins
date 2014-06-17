require 'open-uri'

module LocalBitcoins
  module Market_Data

  # LocalBitcoins.com provides public trade data available for market chart services and tickers
  # The API is in bitcoincharts.com format
  # Currently supported currencies:
  # ARS, AUD, BRL, CAD, CHF, CZK, DKK, EUR, GBP, HKD, ILS, INR, MXN, NOK, NZD, PLN, RUB, SEK, SGD, THB, USD, ZAR

  root = 'https://localbitcoins.com'

    def ticker
      ticker_uri = open("#{root}/bitcoinaverage/ticker-all-currencies/")
      ticker_uri.read if response.status.first=='200'
    end

    def trades(currency)
      trade_uri = open("#{root}/bitcoincharts/#{currency}/trades.json")
      trade_uri.read if response.status.first=='200'
    end

    def orderbook(currency)
      orderbook_uri = open("#{root}/bitcoincharts/#{currency}/orderbook.json")
      orderbook_uri.read if response.status.first=='200'
    end
  end
end