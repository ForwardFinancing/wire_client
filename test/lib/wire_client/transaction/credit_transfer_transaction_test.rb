require 'test_helper'

describe WireClient::CreditTransferTransaction do
  describe :initialize do
    it 'should initialize a valid transaction' do
      subject = WireClient::CreditTransferTransaction.new(
        name: 'Some Merchant',
        wire_routing_number: '111900659',
        agent_name: 'BANK OF AMERICA',
        account_number: '3019586020',
        amount: 102.50,
        reference: 'XYZ-1234/123',
      )
      assert subject.valid?

      subject = WireClient::CreditTransferTransaction.new(
        name: 'Telekomiker AG',
        iban: 'DE37112589611964645802',
        bic: 'PBNKDEFF370',
        amount: 102.50,
        currency: 'EUR',
        reference: 'XYZ-1234/123',
        remittance_information: 'Rechnung 123 vom 22.08.2013'
      )
      assert subject.valid?
    end
  end
end
