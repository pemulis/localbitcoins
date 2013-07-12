require 'spec_helper'

describe 'LocalBitcoins' do
  describe '.new' do
    it 'returns a new client instance' do
      LocalBitcoins.new.should be_a LocalBitcoins::Client
    end
  end

  describe '.configure' do
    it 'sets a global configuration options' do
      r = LocalBitcoins.configure(client_id: 'TEST_ID', client_secret: 'TEST_SECRET')
      r.should be_a Hash
      r.should have_key(:client_id)
      r.should have_key(:client_secret)
      r[:client_id].should eql('TEST_ID')
      r[:client_secret].should eql('TEST_SECRET')
    end

    it 'raises ConfigurationError on invalid config parameter' do
      proc { LocalBitcoins.configure(nil) }.
        should raise_error(ArgumentError, "Options hash required.")

      proc { LocalBitcoins.configure('foo') }.
        should raise_error ArgumentError, "Options hash required."
    end
  end

  describe '.configuration' do
    before do
      LocalBitcoins.configure(client_id: 'TEST_ID', client_secret: 'TEST_SECRET')
    end

    it 'returns global configuration options' do
      r = LocalBitcoins.configuration
      r.should be_a Hash
      r.should have_key(:client_id)
      r.should have_key(:client_secret)
      r[:client_id].should eql('TEST_ID')
      r[:client_secret].should eql('TEST_SECRET')
    end
  end

  describe '.reset_configuration' do
    before do
      LocalBitcoins.configure(client_id: 'TEST_ID', client_secret: 'TEST_SECRET')
    end

    it 'resets global configuration options' do
      LocalBitcoins.reset_configuration
      LocalBitcoins.configuration.should eql({})
    end
  end
end
