# LocalBitcoins API Gem 0.0.4

This gem provides a simple, extensible Ruby wrapper to access the [LocalBitcoins API](https://localbitcoins.com/api-docs/).

## Installation

Install the gem:
```
gem install localbitcoins
```

Or include it in your Gemfile:
```
gem 'localbitcoins'
```

You can use the gem with or without OAuth2 for authentication. Without authentication the API only allows access to the public endpoints, documented [here (Ad Listings)](https://localbitcoins.com/api-docs/public/) and [here (Market Data)](https://localbitcoins.com/api-docs/#toc7)
### Authenticated Usage

### Setting Up Your OAuth2 Client 

For authenticated requests to the LocalBitcoins API, you must [register your application](https://localbitcoins.com/accounts/api/) and get your API credentials. Use the Client ID and Client Secret to receive an access token via OAuth2. There are a number of ways to implement OAuth2, and it is largely left up to you to decide how to do it. If you've never used OAuth2 before, reading [this tutorial](http://aaronparecki.com/articles/2012/07/29/1/oauth2-simplified) is a good place to start!

Once you have your token, you can get to setting up the LocalBitcoins client.

```
# Authenticated

# long version
client = LocalBitcoins::Client.new(
  client_id:     'CLIENT_ID',
  client_secret: 'CLIENT_SECRET',
  oauth_token:   'OAUTH_TOKEN'
)
# slightly shorter version
client = LocalBitcoins.new(
  client_id:     'CLIENT_ID',
  client_secret: 'CLIENT_SECRET',
  oauth_token:   'OAUTH_TOKEN'
)

# Unauthenticated
client = LocalBitcoins.new

```

### Global Configuration

To make things easier, you can define your client credentials at a global level:

``` ruby
# Set the configuration
LocalBitcoins.configure(
  client_id: 'CLIENT_ID',
  client_secret: 'CLIENT_SECRET'
)

# Get the configuration
LocalBitcoins.configuration # => { client_id => 'CLIENT_ID', client_secret => 'CLIENT_SECRET' }

# Reset the configuration
LocalBitcoins.reset_configuration
```

If you're using Rails, you can set the configuration with an initializer file in `config/initializers`.

REMEMBER: Keep your client credentials secret! Do not include them in git repos, or place them anywhere that users can see them. If you suspect that your credentials have been accessed by someone else, immediately reset your client secret from your LocalBitcoins Apps Dashboard.

There are several ways to solve the problem of keeping your credentials secret. For Rails apps, I like to store them as environment variables and access them with [figaro](https://github.com/laserlemon/figaro).

## Usage

Nearly every endpoint found [in the documentation](https://localbitcoins.com/api-docs) is supported by this gem. Rather than document every method here, we encourage you to read the source to find the function you're looking for.

The modules for groups of endpoints are located in `/localbitcoins/client/`

### Ads

You can get a list of the token owner's ads with the following method:

``` ruby
ads = client.ads

ads.ad_list.each do |a|
  a.data.visible    # => boolean value of the ad's visibility
  a.data.email      # => valid e-mail string or null
  a.data.location_string # => human-readable location
  # and many more pieces of data!
end
```

For a full list of info you can get with this method, view the [API documentation](https://localbitcoins.com/api-docs/).


You can get a list of the token owner's releaseable escrows through the OAuth client. You can also use the client to release an escrow.

### View Releaseable Escrows

``` ruby
escrows = client.escrows

escrows.escrow_list.each do |e|
  e.data.created_at     # => UTC datetime escrow was created at
  e.data.buyer_username # => username of the buyer
  e.data.reference_code # => reference code for the escrow
  
  e.actions.release_url # => url to release to escrow
end
```

Use the release_url from `escrows` method in the `escrow_release` method below:

### Release An Escrow

``` ruby
# returns a complimentary message if the escrow successfully released
release = client.escrow_release(release_url)
```


## License

All code is released under the MIT License.
