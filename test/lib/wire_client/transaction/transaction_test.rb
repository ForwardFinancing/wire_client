require 'test_helper'

describe WireClient::Transaction do
  describe :new do
    it 'should have default for currency' do
      assert_equal WireClient::Transaction.new.currency, 'USD'
    end

    it 'should have default for country' do
      assert_equal WireClient::Transaction.new.country, 'US'
    end

    it 'should have default for country_subdivision' do
      assert_equal WireClient::Transaction.new.country_subdivision, 'MA'
    end

    it 'should have default for clear_system_code' do
      assert_equal WireClient::Transaction.new.clear_system_code, 'USABA'
    end

    it 'should have default for agent_name' do
      assert_equal WireClient::Transaction.new.agent_name, 'NOTPROVIDED'
    end

    it 'should have default for reference' do
      assert_equal WireClient::Transaction.new.reference, 'NOTPROVIDED'
    end

    it 'should have default for requested_date' do
      assert_equal WireClient::Transaction.new.requested_date,
                   Date.new(2016, 8, 11)
    end

    it 'should have default for batch_booking' do
      assert_equal WireClient::Transaction.new.batch_booking, true
    end

    it 'should have default for service_priority' do
      assert_equal WireClient::Transaction.new.service_priority, 'NORM'
    end

    it 'should have default for service_level' do
      assert_equal WireClient::Transaction.new.service_level, 'URGP'
    end
  end

  describe :error_messages do
    it 'should include all error messages' do
      subject = WireClient::Transaction.new
      refute subject.valid?
      assert_includes subject.error_messages,
                      'Name is too short (minimum is 1 character)'
      assert_includes subject.error_messages,
                      'Amount is not a number'
    end
  end

  describe :requested_date do
    it 'should be greater than today by default' do
      subject = WireClient::DirectDebitTransaction.new(
        requested_date: Date.yesterday
      )
      refute subject.valid?
      assert_equal subject.errors[:requested_date].size, 1

      subject = WireClient::CreditTransferTransaction.new(
        requested_date: Date.yesterday
      )
      refute subject.valid?
      assert_equal subject.errors[:requested_date].size, 1
    end
  end

  describe :name do
    it 'should accept valid value' do
      assert_valid_values(
        WireClient::Transaction,
        values: [
          'Manfred Mustermann III.',
          'Zahlemann & Söhne GbR',
          'X' * 70
        ],
        attributes: [:name]
      )
    end

    it 'should not accept invalid value' do
      refute_invalid_values(
        WireClient::Transaction,
        values: [nil, 'X' * 71],
        attributes: [:name]
      )
    end
  end

  describe :country do
    it 'should accept valid value' do
      assert_valid_values(
        WireClient::Transaction,
        values: ['US', 'UK', 'BR', 'FR'],
        attributes: [:country]
      )
    end

    it 'should not accept invalid value' do
      refute_invalid_values(
        WireClient::Transaction,
        values: ['USD', 'invalid', 'etc', 'U'],
        attributes: [:country]
      )
    end
  end

  describe :country_subdivision_abbr do
    it 'should be nil when the country is not the US' do
      subject = WireClient::Transaction.new country: 'AR'
      assert_nil subject.country_subdivision_abbr
    end

    it 'should provide the correct abbreviation for US states' do
      subject = WireClient::Transaction.new country: 'US',
                                        country_subdivision: 'MA'
      assert_equal subject.country_subdivision_abbr, 'MA'
      subject = WireClient::Transaction.new country: 'US',
                                        country_subdivision: 'Massachusetts'
      assert_equal subject.country_subdivision_abbr, 'MA'
    end
  end

  describe :country_subdivision_name do
    it 'should be nil when the country is not the US' do
      subject = WireClient::Transaction.new country: 'AR'
      assert_nil subject.country_subdivision_name
    end

    it 'should provide the correct abbreviation for US states' do
      subject = WireClient::Transaction.new country: 'US',
                                        country_subdivision: 'MA'
      assert_equal subject.country_subdivision_name, 'Massachusetts'
      subject = WireClient::Transaction.new country: 'US',
                                        country_subdivision: 'Massachusetts'
      assert_equal subject.country_subdivision_name, 'Massachusetts'
    end
  end

  describe :iban do
    it 'should accept valid value' do
      assert_valid_values(
        WireClient::Transaction,
        values: ['DE21500500009876543210', 'PL61109010140000071219812874'],
        attributes: [:iban]
      )
    end

    it 'should not accept invalid value' do
      refute_invalid_values(
        WireClient::Transaction,
        values: ['invalid'],
        attributes: [:iban]
      )
    end
  end

  describe :bic do
    it 'should accept valid value' do
      assert_valid_values(
        WireClient::Transaction,
        values: ['DEUTDEFF', 'DEUTDEFF500', 'SPUEDE2UXXX'],
        attributes: [:bic]
      )
    end

    it 'should not accept invalid value' do
      refute_invalid_values(
        WireClient::Transaction,
        values: ['invalid'],
        attributes: [:bic]
      )
    end
  end

  describe :amount do
    it 'should accept valid value' do
      assert_valid_values(
        WireClient::Transaction,
        values: [
          0.01,
          1,
          100,
          100.00,
          99.99,
          1234567890.12,
          BigDecimal('10'),
          '42',
          '42.51',
          '42.512',
          1.23456
        ],
        attributes: [:amount]
      )
    end

    it 'should not accept invalid value' do
      refute_invalid_values(
        WireClient::Transaction,
        values: [nil, 0, -3, 'xz'],
        attributes: [:amount]
      )
    end
  end

  describe :currency do
    it 'should allow valid values' do
      assert_valid_values(
        WireClient::Transaction,
        values: ['EUR', 'CHF', 'SEK'],
        attributes: [:currency]
      )
    end

    it 'should not allow invalid values' do
      refute_invalid_values(
        WireClient::Transaction,
        values: ['', 'EURO', 'ABCDEF'],
        attributes: [:currency]
      )
    end
  end
end
