# LocalBitcoins API Gem 1.0.0

This gem provides a simple, extensible Ruby wrapper to access the [LocalBitcoins API](https://localbitcoins.com/api-docs/).

## Installation & Setup 

Install the gem:
```
gem install localbitcoins
```

Or include it in your Gemfile:
```
gem 'localbitcoins'
```

You can use the gem with or without OAuth2 for authentication. Without authentication the API only allows access to the public endpoints documented [here (Ad Listings)](https://localbitcoins.com/api-docs/public/) and [here (Market Data)](https://localbitcoins.com/api-docs/#toc7)

### Setting Up The Client 

For authenticated requests to the LocalBitcoins API, you must [register your application](https://localbitcoins.com/accounts/api/) and get your API credentials. Use the Client ID and Client Secret to receive an access token via OAuth2. There are a number of ways to implement OAuth2, and it is largely left up to you to decide how to do it. If you've never used OAuth2 before, reading [this tutorial](http://aaronparecki.com/articles/2012/07/29/1/oauth2-simplified) is a good place to start!

Once you have your token, you can get to setting up the LocalBitcoins client.

``` ruby
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

Nearly every endpoint found in both the [logged in](https://localbitcoins.com/api-docs) and [public](https://localbitcoins.com/api-docs/public/) documentation is supported by this gem.

### Ads

Return a list of the token owner's ads with the following method:

``` ruby
ads = client.ads

ads.ad_list.each do |a|
  a.data.visible    # => boolean value of the ad's visibility
  a.data.email      # => valid e-mail string or null
  a.data.location_string # => human-readable location
  # and many more pieces of data!
end
```
Create a new ad for the token owner:

``` ruby
# - Required fields -
# min_amount                - minimum amount for sale in fiat [string]
# max_amount                - maximum amount for sale in fiat [string]
# price_equation            - price using price equation operators [string]
# lat                       - latitude of location [float]
# lon                       - longitude of location [float]
# city                      - city of listing [string]
# location_string           - text representation of location [string]
# countrycode               - two letter countrycode [string]
# account_info              - [string]
# bank_name                 - [string]
# sms_verification_required - only receive contacts with verified phone numbers [boolean]
# track_max_amount          - decrease max sell amount in relation to liquidity [boolean]
# trusted_required          - only allow trusted contacts [boolean]
# currency                  - three letter fiat representation [string]
#
# pass a hash of the above fields
# returns a message on success
client.create_ad(params)
```

Update existing ad for the token owner.

``` ruby
# - Required Fields -
# id             - id of the ad you want to update
# visibility     - the ad's visibility [boolean]
# price_equation - equation to calculate price [string]
#
# NOTE 1: Setting min_amount or max_amount to nil will unset them.
# NOTE 2: "Floating price" must be false in you ad's edit form for price_equation to go through
#
# pass a hash of the above fields, plus any other editable fields
# returns a message on success
client.update_ad(id,params)
``` 

List of ads from a comma separated string of ids
``` ruby
# pass a comma separated string of ids
ads = client.ad_list("12345,123456,1234567")
``` 
Gets a single ad from its id

``` ruby
ad = client.ad(12345)
```
### Escrows

View token owner's releasable escrows
NOTE: This endpoint is not documented by LocalBitcoins and may or may not work.
``` ruby
escrows = client.escrows
# escrows are listed in escrows.escrow_list
```
Release an escrow

``` ruby
# pass the id of the contact which the escrow is associated with
# returns a complimentary message if the escrow successfully released
release = client.escrow_release(contact_id)
```

### Contacts

List of active contacts
``` ruby
# This method can filter contacts by contact_type, which can be "buyer" or "seller"
#
# buyers and sellers
contacts = client.active_contacts
# buyers only
contacts = client.active_contacts('buyer')
# sellers only 
contacts = client.active_contacts('seller')
```

Released, canceled, and closed contacts have their own methods as well, which can be filtered the same as above.
``` ruby
released = client.released_contacts
closed = client.closed_contacts
canceled = client.canceled_contacts
``` 

Get a contact based on the id
``` ruby
released = client.released_contacts
closed = client.closed_contacts
canceled = client.canceled_contacts
``` 

Get a contact based on the id
``` ruby
contact = client.contact_info(1234)
```

Get a list of contacts from a comma separated string of ids
``` ruby
contacts = client.contacts_info("1234,12345,1234567")
# access list at contacts.contact_list
```

Create a new contact for the token owner
``` ruby
client.create_contact(ad_id, amount, message)
```

Fund an active contact for the token owner
``` ruby
client.fund_contact(contact_id)
```

Cancel an active contact for the token owner
``` ruby
client.cancel_contact(contact_id)
```

Initiate a dispute with on a contact for the token owner
``` ruby
client.dispute_contact(contact_id)
```

Send a message to a contact for the token owner
``` ruby
client.message_contact(contact_id, message)
```

Return all messages from a contact
``` ruby
messages = client.messages_from_contact(contact_id)
```

Mark a contact as paid for the token owner
``` ruby
client.mark_contact_as_paid(contact_id)
```

### Users

Return info on the token owner
``` ruby
myself = client.myself
```

Return an account based on the username.
``` ruby
user = client.account_info(username)
```

Immediately expire the currently authorized access_token.
NOTE: This method may not work. We're looking into it.
``` ruby
client.logout
```

### Wallet

Return info on the token owner's wallet
``` ruby
wallet = client.wallet
```

Return the token owner's wallet balance
``` ruby
balance = client.wallet_balance
```

Return the address of the token owner's wallet
``` ruby
address = client.wallet_addr
```

Send bitcoin from the token owner's wallet
``` ruby
# returns message on success
client.wallet_send(address, amount)
```
NOTE: The LocalBitcoins documentation does not specify where pins can be acquired, though use of a pin requires the 'money_pin' token scope.

Send bitcoin from token owner's wallet using pin code
``` ruby
#returns message no success
client.wallet_pin_send(address, amount, pin)
```

Check if a pin is valid
``` ruby
client.valid_pin?(pin)
```

## Public API

### Markets
Return a ticker of bitcoin prices in various currencies.
``` ruby
ticker = client.ticker
```

Return a batch of 500 trades in the specifed currency
``` ruby
# currency is the 3 letter currency code
trades = client.trades(currency)

# since is an optional trade id - will return the next 500 trades after the specifed id
trades = client.trades(currency, 12345) 
```

Return the LocalBitcoins online orderbook ( Bids and Asks ) in a specified currency
``` ruby
# currency is the 3 letter currency code
orderbook = client.orderbook(currency)
```

### Ad Listings

Return a list of online buy ads pertaining to specified parameters
``` ruby
# Accepts a hash of parameters, with a valid subset of the following keys: countrycode, currency, country_name, payment_method
#
# Valid API endpoints include:
# /buy-bitcoins-online/{countrycode}/{country_name}/{payment_method}/.json
# /buy-bitcoins-online/{countrycode}/{country_name}/.json
# /buy-bitcoins-online/{currency}/{payment_method}/.json
# /buy-bitcoins-online/{currency}/.json
# /buy-bitcoins-online/{payment_method}/.json
# /buy-bitcoins-online/.json
#
# NOTE: countrycode must be 2 characters and currency must be 3 characters
online_buy_ads_lookup = client.online_buy_ads_lookup(params)
```

Return a list of online sell ads pertaining to specified parameters
``` ruby
# Accepts a hash of parameters, with a valid subset of the following keys: countrycode, currency, country_name, payment_method
#
# NOTE: see valid API endpoints in online_buy_ads_lookup method above
online_sell_ads_lookup = client.online_sell_ads_lookup(params)
```

Returns a list of local buy ads in a certain place
``` ruby
# - Required fields -
# location_id               - id for location found using places method
# location_slug             - slug name for location found using places method
#
# - Optional fields -
# lat                       - latitude of location [float]
# lon                       - longitude of location [float]
#
# pass a hash of the above fields
local_buy_ad = client.local_buy_ad(params)
```

Return a list of local sell ads in a certain place
``` ruby
# pass a hash with the same fields as local_buy_ad
local_sell_ad = client.local_sell_ad(params)
```

### Additional Public Methods

Return all payment methods accepted on LocalBitcoins, with an option to limit the search to a specific country
``` ruby
# countrycode is the 2 character countrycode
payment_methods = client.payment_methods(countrycode)
```

Return all currencies accepted by the LocalBitcoins platform
``` ruby
currencies = client.currencies
```

Return information about the place at or near a specified latitude and longitude
``` ruby
# - Required fields -
# lat                       - latitude of location [float]
# lon                       - longitude of location [float]
#
# - Optional fields -
# countrycode               - 2 letter countrycode
# location_string           - location name in string form
#
# pass a hash of the above fields
places = client.places(params)
```


## License

All code is released under the MIT License.
