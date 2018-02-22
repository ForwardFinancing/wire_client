require 'test_helper'

describe WireClient::IBANValidator do
  class Validatable
    include ActiveModel::Model
    attr_accessor :iban, :iban_the_terrible
    validates_with WireClient::IBANValidator, message: "%{value} seems wrong"
    validates_with WireClient::IBANValidator, field_name: :iban_the_terrible
  end

  it 'should accept valid IBAN' do
    assert_valid_values(
      Validatable,
      values: ['DE21500500009876543210', 'PL61109010140000071219812874'],
      attributes: [:iban, :iban_the_terrible]
    )
  end

  it 'should not accept an invalid IBAN' do
    refute_invalid_values(
      Validatable,
      values: [
        'xxx',                        # Oviously no IBAN
        'DE22500500009876543210',     # wrong checksum
        'DE2150050000987654321',      # too short
        'de87200500001234567890',     # downcase characters
        'DE87 2005 0000 1234 5678 90' # spaces included
      ],
      attributes: [:iban, :iban_the_terrible]
    )
  end

  it "should customize error message" do
    subject = Validatable.new(:iban => 'xxx')
    subject.validate
    assert_equal subject.errors[:iban].first, 'xxx seems wrong'
  end
end

describe WireClient::BICValidator do
  class Validatable
    include ActiveModel::Model
    attr_accessor :bic, :custom_bic
    validates_with WireClient::BICValidator, message: "%{value} seems wrong"
    validates_with WireClient::BICValidator, field_name: :custom_bic
  end

  it 'should accept valid BICs' do
    assert_valid_values(
      Validatable,
      values: ['DEUTDEDBDUE', 'DUSSDEDDXXX'],
      attributes: [:bic, :custom_bic]
    )
  end

  it 'should not accept an invalid BIC' do
    refute_invalid_values(
      Validatable,
      values: ['GENODE61HR', 'DEUTDEDBDUEDEUTDEDBDUE'],
      attributes: [:bic, :custom_bic]
    )
  end

  it "should customize error message" do
    subject = Validatable.new(:bic => 'xxx')
    subject.validate
    assert_equal subject.errors[:bic].first, 'xxx seems wrong'
  end
end

describe WireClient::CreditorIdentifierValidator do
  class Validatable
    include ActiveModel::Model
    attr_accessor :identifier, :crid
    validates_with WireClient::CreditorIdentifierValidator,
                   message: "%{value} seems wrong"
    validates_with WireClient::CreditorIdentifierValidator, field_name: :crid
  end

  it 'should accept valid identifier' do
    assert_valid_values(
      Validatable,
      values: [
        'DE98ZZZ09999999999',
        'AT12ZZZ00000000001',
        'FR12ZZZ123456',
        'NL97ZZZ123456780001'
      ],
      attributes: [:identifier, :crid]
    )
  end

  it 'should not accept an invalid identifier' do
    refute_invalid_values(
      Validatable,
      values: ['x' * 36],
      attributes: [:identifier, :crid]
    )
  end

  it "should customize error message" do
    subject = Validatable.new(:identifier => 'x' * 36)
    subject.validate
    assert_equal subject.errors[:identifier].first, "#{'x' * 36} seems wrong"
  end
end

describe WireClient::MandateIdentifierValidator do
  class Validatable
    include ActiveModel::Model
    attr_accessor :mandate_id, :mid
    validates_with WireClient::MandateIdentifierValidator,
                   message: "%{value} seems wrong"
    validates_with WireClient::MandateIdentifierValidator, field_name: :mid
  end

  it 'should accept valid mandate_identifier' do
    assert_valid_values(
      Validatable,
      values: ['XYZ-123', "+?/-:().,'", 'X' * 35],
      attributes: [:mandate_id, :mid]
    )
  end

  it 'should not accept an invalid mandate_identifier' do
    refute_invalid_values(
      Validatable,
      values: ['ABC 123', '#/*', 'Ümläüt', 'X' * 36],
      attributes: [:mandate_id, :mid]
    )
  end

  it "should customize error message" do
    subject = Validatable.new(:mandate_id => 'ABC 123')
    subject.validate
    assert_equal subject.errors[:mandate_id].first, 'ABC 123 seems wrong'
  end
end
