module WireClient
  class CreditorAccount < Account
    def custom_defaults
      @charge_bearer ||= 'DEBT'
    end
  end
end
