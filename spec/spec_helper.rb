$:.unshift File.expand_path("../..", __FILE__)

require 'localbitcoins'
require 'rest-client'
require 'webmock'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.color = true
end

def stub_auth(method, path, fixture_name, params={})
  headers = {}

  if client.use_hmac
    headers['Apiauth-Key'] = 'CLIENT_ID'
    headers['Apiauth-Nonce'] = /\d+/
    headers['Apiauth-Signature'] = /[a-f0-9]+/
  else
    headers['Authorization'] = 'Bearer ACCESS_TOKEN'
    params['access_token'] = 'ACCESS_TOKEN'
  end

  stub_request(method, api_url(path))
    .with(query: hash_including(params), headers: headers)
    .to_return(status: 200, body: fixture(fixture_name), headers: {})
end

def stub_get(path, fixture_name, params={})
  stub_auth(:get, path, fixture_name, params)
end

def stub_post(path, fixture_name)
  stub_auth(:post, path, fixture_name)
end

def stub_get_unauth(path, fixture_name)
  stub_request(:get, api_url(path))
    .to_return(status: 200, body: fixture(fixture_name), headers: {})
end

def fixture_path(file=nil)
  path = File.expand_path("../fixtures", __FILE__)
  file.nil? ? path : File.join(path, file)
end

def fixture(file)
  File.read(fixture_path(file))
end

def api_url(path)
  "#{LocalBitcoins::Request::API_URL}#{path}"
end
