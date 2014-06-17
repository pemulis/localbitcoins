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
    def update_ad(id, params)
      old_ad = oauth_request(:get, "/api/ad-get/#{id}/")
      old_ad = Hashie::Mash.new(old_ad['data']['ad_list'][0]['data'])
      updated_params = {
          :min_amount => old_ad.min_amount,
          :max_amount => old_ad.max_amount,
          :visible    => true
      }.merge(params)
      oauth_request(:post, "/api/ad/#{id}/", updated_params)
    end

    def create_ad(params)
      oauth_request(:post, '/api/ad-create/', params)

    end
  end
end
