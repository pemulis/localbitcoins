require 'localbitcoins/version'
require 'localbitcoins/errors'
require 'localbitcoins/request'
require 'localbitcoins/client'

module LocalBitcoins
  @@options = {}

  # Create a new LocalBitcoins::Client instance
  #
  def self.new(options={})
    LocalBitcoins::Client.new(options)
  end

  # Define a global configuration
  #
  # options[:api_key]     - client key
  # options[:api_secret]  - client secret
  #
  def self.configure(options={})
    unless options.kind_of?(Hash)
      raise ArgumentError, "Options hash required."
    end
    
    @@options[:api_key]    = options[:api_key]
    @@options[:api_secret] = options[:api_secret]
    @@options
  end
  
  # Returns global configuration hash
  #
  def self.configuration
    @@options
  end
  
  # Resets the global configuration
  #
  def self.reset_configuration
    @@options = {}
  end
end
