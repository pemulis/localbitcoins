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
    def ad_edit(ad_id, update_hash)
      old_hash = oauth_request(:get, "/api/ad-get/#{ad_id}/")
      update_hash.each do |key|
          old_hash[key] = update_hash[key]
      end
      #result = URI.encode(old_hash.map{|k,v|"#{k}=#{v}"}.join("&"))
      oauth_request(:post, "/api/ad-get/#{ad_id}/", old_hash)
    end

    def ad_create(hash)
      #result = URI.encode(hash.map{|k,v|"#{k}=#{v}"}.join("&"))
      oauth_request(:post, '/api/ad-create/', hash)
    end
  end
end
