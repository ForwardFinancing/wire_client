module WireClient
  class DebtorAccount < Account
    def custom_defaults
      @charge_bearer ||= 'DEBT'
    end
  end
end
