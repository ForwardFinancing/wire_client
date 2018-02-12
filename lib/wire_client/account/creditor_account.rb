module WireClient
  class CreditorAccount < Account
    def custom_defaults
      @charge_bearer ||= 'CRED'
    end
  end
end
