module WireClient
  # Base concern for providers like SVB that use an SFTP system instead of API
  module SftpProvider
    extend ActiveSupport::Concern
    include AchClient::SftpProvider

    included do
      # @return [String] Hostname/URL of SVB's "Direct File Transmission" server
      class_attribute :host

      # @return [String] The username they gave you to login to the server
      class_attribute :username

      # @return [String] The password they gave you to login to the server
      class_attribute :password

      # @return [String] The private ssh key that matches the public ssh key you
      # provided to SVB, ie the output of `cat path/to/private/ssh/key`
      class_attribute :private_ssh_key

      # @return [String | NilClass] Passphrase for your private ssh key
      # (if applicable)
      class_attribute :passphrase

      # @return [String] The path on the remote server to the directory where
      # you will deposit your outgoing NACHA files
      class_attribute :outgoing_path

      # @return [String] The path on the remote server to the directory where
      # the SFTP provider will deposit return/confirmation files
      class_attribute :incoming_path

      # @return [Proc] A function that defines the filenaming strategy for your
      # provider. The function should take an optional batch number and return
      # a filename string
      class_attribute :file_naming_strategy
    end
  end
end
