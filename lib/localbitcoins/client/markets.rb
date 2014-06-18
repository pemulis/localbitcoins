require 'open-uri'

module LocalBitcoins
  module Markets

  # LocalBitcoins.com provides public trade data available for market chart services and tickers
  # The API is in bitcoincharts.com format
  # Currently supported currencies:
  # ARS, AUD, BRL, CAD, CHF, CZK, DKK, EUR, GBP, HKD, ILS, INR, MXN, NOK, NZD, PLN, RUB, SEK, SGD, THB, USD, ZAR

  ROOT = 'https://localbitcoins.com'

    def ticker
      ticker_uri = open("#{ROOT}/bitcoinaverage/ticker-all-currencies/")
      ticker_uri.read if ticker_uri.status.first=='200'
    end

    def trades(currency)
      trade_uri = open("#{ROOT}/bitcoincharts/#{currency}/trades.json")
      trade_uri.read if trade_uri.status.first=='200'
    end

    def orderbook(currency)
      orderbook_uri = open("#{ROOT}/bitcoincharts/#{currency}/orderbook.json")
      orderbook_uri.read if orderbook_uri.status.first=='200'
    end
  end
end