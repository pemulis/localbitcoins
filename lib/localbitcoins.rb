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
  # options[:client_id]
  # options[:client_secret]
  #
  def self.configure(options={})
    unless options.kind_of?(Hash)
      raise ArgumentError, "Options hash required."
    end

    @@options[:client_id]     = options[:client_id]
    @@options[:client_secret] = options[:client_secret]
    @@options[:use_hmac]      = options[:use_hmac]
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
