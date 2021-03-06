require 'test_helper'

class SftpProvider
  class WireDebitBatchTest < MiniTest::Test
    def eur_debit_batch
      sample = WireClient::HSHNordbankHamburg::WireBatch.new(
        transaction_type: WireClient::TransactionTypes::Debit
      )
      sample.add_transaction(
        name: 'Zahlemann & Söhne GbR',
        bic: 'SPUEDE2UXXX',
        iban: 'DE21500500009876543210',
        amount: 102.50,
        mandate_date_of_signature: Date.new(2016,8,11),
        mandate_id: 'K-02-2011-12345',
        country: 'GR',
        currency: 'EUR',
        remittance_information: 'Rechnung vom 22.08.2013',
        original_debtor_account: 'NL08RABO0135742099',
        same_mandate_new_debtor_agent: true,
        instruction: '1234/ABC'
      )
      sample
    end

    def gbp_debit_batch
      sample = WireClient::HSHNordbankHamburg::WireBatch.new(
        transaction_type: WireClient::TransactionTypes::Debit
      )
      sample.add_transaction(
        name: 'UK Corp',
        bic: 'NWBKGB2LXXX',
        iban: 'GB29NWBK60161331926819',
        amount: 102.50,
        mandate_date_of_signature: Date.new(2016,8,11),
        mandate_id: 'K-02-2011-12345',
        country: 'UK',
        currency: 'GBP',
        remittance_information: 'Rechnung vom 22.08.2013',
        same_mandate_new_debtor_agent: true,
        instruction: '1234/ABC'
      )
      sample
    end

    def usd_debit_batch
      sample = WireClient::HSHNordbankHamburg::WireBatch.new(
        transaction_type: WireClient::TransactionTypes::Debit
      )
      sample.add_transaction(
        name: 'Zahlemann & Söhne GbR',
        bic: 'SPUEDE2UXXX',
        iban: 'DE21500500009876543210',
        amount: 102.50,
        mandate_date_of_signature: Date.new(2016,8,11),
        mandate_id: 'K-02-2011-12345',
        country: 'GR',
        currency: 'EUR'
      )
      sample
    end

    def conn_info
      lambda do |host, username, options|
        assert_equal WireClient::HSHNordbankHamburg.host, host
        assert_equal WireClient::HSHNordbankHamburg.username, username
        assert_equal ({
          key_data: [WireClient::HSHNordbankHamburg.private_ssh_key],
          password: WireClient::HSHNordbankHamburg.password,
        }), options
      end
    end

    def test_send_eur_batch
      sftp_mock = Minitest::Mock.new
      Net::SFTP.stub :start, conn_info, sftp_mock do
        file_path, file_body = eur_debit_batch.send_batch
        assert_equal "/root/wire_sandbox/Inbox/WIRE08111601.xml", file_path
        assert_includes file_body, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Document xmlns=\"urn:iso:std:iso:20022:tech:xsd:pain.008.001.02\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"urn:iso:std:iso:20022:tech:xsd:pain.008.001.02 pain.008.001.02.xsd\">"
        assert_includes file_body, "<CreDtTm>2016-08-11"
        assert_includes file_body, "<ChrgBr>CRED</ChrgBr>"
        assert_includes file_body, "<Nm>Business from Germany</Nm>"
        assert_includes file_body, "<IBAN>#{WireClient::HSHNordbankHamburg::WireBatch.initiator_iban}</IBAN>"
        assert_includes file_body, "<InstdAmt Ccy=\"EUR\">102.50</InstdAmt>"
        assert_includes file_body, "<Nm>Zahlemann &amp; Söhne GbR</Nm>"
        assert_includes file_body, "<IBAN>DE21500500009876543210</IBAN>"
      end
      sftp_mock.verify
    end

    def test_send_gbp_batch
      sftp_mock = Minitest::Mock.new
      Net::SFTP.stub :start, conn_info, sftp_mock do
        file_path, file_body = gbp_debit_batch.send_batch
        assert_equal "/root/wire_sandbox/Inbox/WIRE08111601.xml", file_path
        assert_includes file_body, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Document xmlns=\"urn:iso:std:iso:20022:tech:xsd:pain.008.001.02\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"urn:iso:std:iso:20022:tech:xsd:pain.008.001.02 pain.008.001.02.xsd\">"
        assert_includes file_body, "<CreDtTm>2016-08-11"
        assert_includes file_body, "<ChrgBr>CRED</ChrgBr>"
        assert_includes file_body, "<Nm>Business from Germany</Nm>"
        assert_includes file_body, "<IBAN>#{WireClient::HSHNordbankHamburg::WireBatch.initiator_iban}</IBAN>"
        assert_includes file_body, "<InstdAmt Ccy=\"GBP\">102.50</InstdAmt>"
        assert_includes file_body, "<Nm>UK Corp</Nm>"
        assert_includes file_body, "<IBAN>GB29NWBK60161331926819</IBAN>"
      end
      sftp_mock.verify
    end

    def test_send_usd_batch
      sftp_mock = Minitest::Mock.new
      Net::SFTP.stub :start, conn_info, sftp_mock do
        file_path, file_body = usd_debit_batch.send_batch
        assert_equal "/root/wire_sandbox/Inbox/WIRE08111601.xml", file_path
        assert_includes file_body, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Document xmlns=\"urn:iso:std:iso:20022:tech:xsd:pain.008.001.02\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"urn:iso:std:iso:20022:tech:xsd:pain.008.001.02 pain.008.001.02.xsd\">"
        assert_includes file_body, "<CreDtTm>2016-08-11"
        assert_includes file_body, "<ChrgBr>CRED</ChrgBr>"
        assert_includes file_body, "<Nm>Business from Germany</Nm>"
        assert_includes file_body, "<IBAN>#{WireClient::HSHNordbankHamburg::WireBatch.initiator_iban}</IBAN>"
        assert_includes file_body, "<InstdAmt Ccy=\"EUR\">102.50</InstdAmt>"
        assert_includes file_body, "<Nm>Zahlemann &amp; Söhne GbR</Nm>"
        assert_includes file_body, "<IBAN>DE21500500009876543210</IBAN>"
      end
      sftp_mock.verify
    end
  end
end
