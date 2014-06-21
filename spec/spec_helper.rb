$:.unshift File.expand_path("../..", __FILE__)

require 'localbitcoins'
require 'rest-client'
require 'webmock'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.color = true
end

def stub_get(path, fixture_name, params={})
  stub_request(:get, api_url(path)).
         with(:query => {"Accept" => "application/json", "access_token" => "ACCESS_TOKEN"}.merge!(params),
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization'=>'Bearer ACCESS_TOKEN','Content-Type'=>'application/x-www-form-urlencoded',
                           'User-Agent'=>'Faraday v0.9.0'}).to_return(:status => 200, :body => fixture(fixture_name),
                                                                      :headers => {})
end

def stub_get_unauth(path, fixture_name)
  stub_request(:get, api_url(path)).
      with(
      # :query => {"Accept" => "application/json"},
           :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                        #'Content-Type'=>'application/x-www-form-urlencoded',
                        'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => fixture(fixture_name),
                                                                   :headers => {})
end

def stub_post(path, fixture_name)
  stub_request(:post, api_url(path)).
      with(:query => {"Accept" => "application/json", "access_token" => "ACCESS_TOKEN"},
           :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                        'Authorization'=>'Bearer ACCESS_TOKEN', 'Content-Type'=>'application/x-www-form-urlencoded',
                        'User-Agent'=>'Faraday v0.9.0'}).to_return(:status => 200, :body => fixture(fixture_name),
                                                                   :headers => {})
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
