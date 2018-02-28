require 'test_helper'

describe WireClient::CreditorAccount do
  it 'should initialize a new account' do
    subject = WireClient::CreditorAccount.new(
      name: 'Some Merchant',
      wire_routing_number: '111900659',
      account_number: '3019586020',
      identifier: '012093293'
    )
    assert subject.valid?

    subject = WireClient::CreditorAccount.new(
      name: 'Gläubiger GmbH',
      bic: 'BANKDEFFXXX',
      iban: 'DE87200500001234567890',
      identifier: 'DE98ZZZ09999999999'
    )
    assert subject.valid?
  end

  it 'should have default for charge_bearer' do
    assert_equal WireClient::CreditorAccount.new.charge_bearer, 'CRED'
  end
end
