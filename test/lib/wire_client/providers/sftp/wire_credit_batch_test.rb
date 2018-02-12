require 'test_helper'

class SftpProvider
  class WireCreditBatchTest < MiniTest::Test
    def conn_info
      lambda do |host, username, options|
        assert_equal WireClient::HSBC.host, host
        assert_equal WireClient::HSBC.username, username
        assert_equal ({
          key_data: [WireClient::HSBC.private_ssh_key],
          password: WireClient::HSBC.password,
        }), options
      end
    end

    def first_credit_batch
      sample = WireClient::HSBC::WireBatch.new(
        transaction_type: WireClient::TransactionTypes::Credit
      )
      sample.add_transaction(
        name: 'Some Merchant',
        wire_routing_number: '111900659',
        agent_name: 'BANK OF AMERICA',
        account_number: '3019586020',
        country: 'US',
        amount: 102.50
      )
      sample
    end

    def test_send_first_batch
      sftp_mock = Minitest::Mock.new
      Net::SFTP.stub :start, conn_info, sftp_mock do
        file_path, file_body = first_credit_batch.send_batch
        assert_equal "/root/wire_sandbox/Inbox/WIRE08111601.xml", file_path
        assert_includes file_body, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Document xmlns=\"urn:iso:std:iso:20022:tech:xsd:pain.001.001.03\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"urn:iso:std:iso:20022:tech:xsd:pain.001.001.03 pain.001.001.03.xsd\">"
        assert_includes file_body, "<CreDtTm>2016-08-11"
        assert_includes file_body, "<ChrgBr>DEBT</ChrgBr>"
        assert_includes file_body, "<Nm>#{WireClient::HSBC::WireBatch.initiator_name}</Nm>"
        assert_includes file_body, "<Ctry>US</Ctry>"
        assert_includes file_body, "<CtrySubDvsn>MA</CtrySubDvsn>"
        assert_includes file_body, "<Id>#{WireClient::HSBC::WireBatch.initiator_identifier}</Id>"
        assert_includes file_body, "<Id>#{WireClient::HSBC::WireBatch.initiator_account_number}</Id>"
        assert_includes file_body, "<MmbId>#{WireClient::HSBC::WireBatch.initiator_wire_routing_number}</MmbId>"
        assert_includes file_body, "<InstdAmt Ccy=\"USD\">102.50</InstdAmt>"
        assert_includes file_body, "<Nm>Some Merchant</Nm>"
        assert_includes file_body, "<Id>3019586020</Id>"
        assert_includes file_body, "<MmbId>111900659</MmbId>"
      end
      sftp_mock.verify
    end

    def second_credit_batch
      sample = WireClient::HSBC::WireBatch.new(
        transaction_type: WireClient::TransactionTypes::Credit
      )
      sample.add_transaction(
        name: 'John Doe from Ohio',
        wire_routing_number: '021000089',
        account_number: '42349053',
        agent_name: 'HSBC',
        country: 'US',
        amount: 202.50
      )
      sample
    end

    def test_send_second_batch
      sftp_mock = Minitest::Mock.new
      Net::SFTP.stub :start, conn_info, sftp_mock do
        file_path, file_body = second_credit_batch.send_batch
        assert_equal "/root/wire_sandbox/Inbox/WIRE08111601.xml", file_path
        assert_includes file_body, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Document xmlns=\"urn:iso:std:iso:20022:tech:xsd:pain.001.001.03\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"urn:iso:std:iso:20022:tech:xsd:pain.001.001.03 pain.001.001.03.xsd\">"
        assert_includes file_body, "<CreDtTm>2016-08-11"
        assert_includes file_body, "<ChrgBr>DEBT</ChrgBr>"
        assert_includes file_body, "<Nm>#{WireClient::HSBC::WireBatch.initiator_name}</Nm>"
        assert_includes file_body, "<Ctry>US</Ctry>"
        assert_includes file_body, "<CtrySubDvsn>MA</CtrySubDvsn>"
        assert_includes file_body, "<Id>#{WireClient::HSBC::WireBatch.initiator_identifier}</Id>"
        assert_includes file_body, "<Id>#{WireClient::HSBC::WireBatch.initiator_account_number}</Id>"
        assert_includes file_body, "<MmbId>#{WireClient::HSBC::WireBatch.initiator_wire_routing_number}</MmbId>"
        assert_includes file_body, "<InstdAmt Ccy=\"USD\">202.50</InstdAmt>"
        assert_includes file_body, "<Nm>John Doe from Ohio</Nm>"
        assert_includes file_body, "<Id>42349053</Id>"
        assert_includes file_body, "<MmbId>021000089</MmbId>"
      end
      sftp_mock.verify
    end
  end
end
