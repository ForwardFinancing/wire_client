require 'test_helper'

class SftpProvider
  class WireBatchTest < MiniTest::Test
    def eur_credit_batch
      sample = WireClient::HSHNordbankHamburg::WireBatch.new(
        transaction_type: WireClient::TransactionTypes::Credit
      )
      sample.add_transaction(
        receptor_name: 'John Doe from Netherlands',
        receptor_swift_code: 'SNSBNL2A',
        receptor_iban: 'NL43SNSB0822007648',
        amount: 102.50,
        currency: 'EUR'
      )
      sample
    end

    def usd_credit_batch
      sample = WireClient::HSHNordbankHamburg::WireBatch.new(
        transaction_type: WireClient::TransactionTypes::Credit
      )
      sample.add_transaction(
        receptor_name: 'John Doe from Netherlands',
        receptor_swift_code: 'SNSBNL2A',
        receptor_iban: 'NL43SNSB0822007648',
        amount: 102.50,
        #currency: 'USD' # by default
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
        file_path, file_body = eur_credit_batch.send_batch
        assert_equal "/root/wire_sandbox/Inbox/WIRE08111601.xml", file_path
        assert_includes file_body, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Document xmlns=\"urn:iso:std:iso:20022:tech:xsd:pain.001.001.03\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"urn:iso:std:iso:20022:tech:xsd:pain.001.001.03 pain.001.001.03.xsd\">"
        assert_includes file_body, "<CreDtTm>2016-08-11"
        assert_includes file_body, "<Nm>Business from Germany</Nm>"
        assert_includes file_body, "<IBAN>#{WireClient::HSHNordbankHamburg::WireBatch.initiator_iban}</IBAN>"
        assert_includes file_body, "<InstdAmt Ccy=\"EUR\">102.50</InstdAmt>"
        assert_includes file_body, "<Nm>John Doe from Netherlands</Nm>"
        assert_includes file_body, "<IBAN>NL43SNSB0822007648</IBAN>"
      end
      sftp_mock.verify
    end

    def test_send_usd_batch
      sftp_mock = Minitest::Mock.new
      Net::SFTP.stub :start, conn_info, sftp_mock do
        file_path, file_body = usd_credit_batch.send_batch
        assert_equal "/root/wire_sandbox/Inbox/WIRE08111601.xml", file_path
        assert_includes file_body, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Document xmlns=\"urn:iso:std:iso:20022:tech:xsd:pain.001.001.03\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"urn:iso:std:iso:20022:tech:xsd:pain.001.001.03 pain.001.001.03.xsd\">"
        assert_includes file_body, "<CreDtTm>2016-08-11"
        assert_includes file_body, "<Nm>Business from Germany</Nm>"
        assert_includes file_body, "<IBAN>#{WireClient::HSHNordbankHamburg::WireBatch.initiator_iban}</IBAN>"
        assert_includes file_body, "<InstdAmt Ccy=\"USD\">102.50</InstdAmt>"
        assert_includes file_body, "<Nm>John Doe from Netherlands</Nm>"
        assert_includes file_body, "<IBAN>NL43SNSB0822007648</IBAN>"
      end
      sftp_mock.verify
    end
  end
end
