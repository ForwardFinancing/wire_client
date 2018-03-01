require 'ach_client'
require 'active_support/all'
require 'active_model'
require 'savon'
require 'sucker_punch'
require 'bigdecimal'
require 'builder'
require 'iban-tools'

# Require all of the files in lib
Dir[File.expand_path('..', __FILE__) + '/**/*.rb'].sort.each do |f|
  require(f.split('/lib/').last.split('.rb').first)
end

# Adapter for interacting with Wire transfer service providers
module WireClient
  include AchClient

  # Enables consumer to interact with new SFTP providers without adding them
  # to the codebase. Let's say the consumer wants to integrate with Citibank.
  # They would invoke WireClient::Citibank, which would be undefined. This
  # const_missing would be called, and the Citibank module would be dynamically
  # defined, with all the necessary SFTP concerns included and ready for use.
  def self.const_missing(name)
    const_set(
      name,
      Class.new do
        include WireClient::SftpProvider

        # Defines the classes within the provider namespace to use for
        # sending transactions
        const_set(:WireBatch, Class.new(WireClient::Sftp::WireBatch))
      end
    )
  end

  def self.today
    if Time.zone.present?
      Time.zone.now.to_date
    else
      Date.today
    end
  end
end
