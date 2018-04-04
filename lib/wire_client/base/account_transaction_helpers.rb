module WireClient
  module AccountTransactionHelpers
    def country_subdivision_abbr
      return US_STATES[@country_subdivision] if a_full_name_us_state?
      @country_subdivision
    end

    def country_subdivision_name
      return US_STATES.key(@country_subdivision) if an_abbreviated_us_state?
      @country_subdivision
    end

    protected

    def within_the_us?
      @country == 'US'
    end

    def an_abrreviated_state_name?
      @country_subdivision.match(/\A[A-Z]{2,2}\z/)
    end

    def an_abbreviated_us_state?
      within_the_us? && an_abrreviated_state_name?
    end

    def a_full_name_us_state?
      within_the_us? && !an_abrreviated_state_name?
    end
  end
end
