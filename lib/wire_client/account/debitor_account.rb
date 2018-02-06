module WireClient
  class DebtorAccount < Account
    def custom_defaults
      @charge_bearer ||= 'CRED'
    end
  end
end
