module LocalBitcoins
  module Ads
    # Get a list of the token owner's ads
    #
    def ads()
      data = oauth_request(:get, '/api/ads/')
      Hashie::Mash.new(data['ad_list'])
    end

    # Update one of the token owner's ads
    #
    # id             - id of the ad you want to update
    # visibility     - the ad's visibility [boolean]
    # min_amount     - minimum selling price [string or nil]
    # max_amount     - maximum buying price [string or nil]
    # price_equation - equation to calculate price [string]
    #
    # NOTE: Omitting min_amount or max_amount will unset them.
    #
    def update_ad(id, visibility, min_amount, max_amount, price_equation)
      # Can't use this method until the Ads API is complete!
    end
  end
end
