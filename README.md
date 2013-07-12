# LocalBitcoins API Gem 0.0.3

This gem provides a simple, extensible Ruby wrapper to access the [LocalBitcoins API](https://localbitcoins.com/api-docs/).

THIS IS A WORK IN PROGRESS AND DOES NOT YET HAVE A TEST SUITE. DO NOT USE THIS IN PRODUCTION APPLICATIONS UNTIL THE TEST SUITE HAS BEEN WRITTEN. THANKS!

## Installation

Install the gem:
```
gem install localbitcoins
```

Or include it in your Gemfile:
```
gem 'openlibrary'
```

## Setting Up Your OAuth Client 

First, you need to [register your application](https://localbitcoins.com/accounts/api/) with LocalBitcoins to get your API keys. You will get a Client ID and a Client Secret, which you will use to get your OAuth access token. An OAuth access token is required for all requests to the LocalBitcoins API. 

There are a number of ways to implement OAuth, and it is largely left up to you to decide how to do it. If you've never used OAuth before, reading [this tutorial](http://aaronparecki.com/articles/2012/07/29/1/oauth2-simplified) is a good place to start!

Once you have your token, you can set up your client with the following code:

``` ruby
# long version
client = LocalBitcoins::Client.new(oauth_token: 'OAUTH_TOKEN')
# short version
client = LocalBitcoins.new(oauth_token: 'OAUTH_TOKEN')
```

### Global Configuration

To make things easier, you can define your client credentials at a global level:

``` ruby
# Set the configuration
LocalBitcoins.configure(
  client_id: 'ID',
  client_secret: 'SECRET'
)

# Get the configuration
LocalBitcoins.configuration # => { client_id => 'ID', client_secret => 'SECRET' }

# Reset the configuration
LocalBitcoins.reset_configuration
```

If you're using Rails, you can set the configuration with an initializer file in `config/initializers`.

REMEMBER: Keep your client credentials secret! Do not include them in git repos, or place them anywhere that users can see them. If you suspect that your credentials have been accessed by someone else, immediately reset your client secret from your LocalBitcoins Apps Dashboard.

There are several ways to solve the problem of keeping your credentials secret. For Rails apps, I like to store them as environment variables and access them with [figaro](https://github.com/laserlemon/figaro).

## Usage

You can get a list of the token owner's releaseable escrows through the OAuth client. You can also use the client to release an escrow.

### View Releaseable Escrows

``` ruby
escrows = client.escrows

escrows.each do |e|
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

### List Ads

You can get a list of the token owner's ads with the following method:

``` ruby
ads = client.ads

ads.each do |a|
  a.data.visible    # => boolean value of the ad's visibility
  a.data.email      # => valid e-mail string or null
  a.data.location_string # => human-readable location
  # and many more pieces of data!
end
```

For a full list of info you can get with this method, view the [API documentation](https://localbitcoins.com/api-docs/).

## License

All code is released under the MIT License.
