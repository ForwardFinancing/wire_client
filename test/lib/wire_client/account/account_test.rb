require 'test_helper'

describe WireClient::Account do
  describe :new do
    it 'should not accept unknown keys' do
      assert_raises(NoMethodError) do
        WireClient::Account.new foo: 'bar'
      end
    end

    it 'should require name and identifier' do
      subject = WireClient::Account.new
      refute subject.valid?
      subject.errors
      assert_equal subject.errors[:name].size, 1
      assert_equal subject.errors[:identifier].size, 1
    end
  end

  describe :name do
    it 'should accept valid value' do
      assert_valid_values(
        WireClient::Account,
        values: [
          'Gläubiger GmbH',
          'Zahlemann & Söhne GbR',
          'X' * 70
        ],
        attributes: [:name]
      )
    end

    it 'should not accept invalid value' do
      refute_invalid_values(
        WireClient::Account,
        values: [nil, 'X' * 71],
        attributes: [:name]
      )
    end
  end

  describe :iban do
    it 'should accept valid value' do
      assert_valid_values(
        WireClient::Account,
        values: [
          'DE21500500009876543210',
          'PL61109010140000071219812874',
        ],
        attributes: [:iban]
      )
    end

    it 'should not accept invalid value' do
      refute_invalid_values(
        WireClient::Account,
        values: ['invalid'],
        attributes: [:iban]
      )
    end
  end

  describe :bic do
    it 'should accept valid value' do
      assert_valid_values(
        WireClient::Account,
        values: [
          'DEUTDEFF',
          'DEUTDEFF500',
          'SPUEDE2UXXX'
        ],
        attributes: [:bic]
      )
    end

    it 'should not accept invalid value' do
      refute_invalid_values(
        WireClient::Account,
        values: ['invalid'],
        attributes: [:bic]
      )
    end
  end
end
