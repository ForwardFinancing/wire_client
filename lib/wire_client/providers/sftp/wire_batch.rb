module WireClient
  # Namespace for all things Sftp
  class Sftp
    # NACHA representation of an AchBatch
    class WireBatch < WireClient::Abstract::WireBatch

      def initialize(transaction_type:, batch_number: nil)
        super(transaction_type: transaction_type)
        @batch_number = batch_number
      end

      # The filename used for the batch
      # @return [String] filename to use
      def batch_file_name
        self.class.parent.file_naming_strategy.(@batch_number)
      end

      # Sends the batch to SFTP provider
      def do_send_batch
        file_path = File.join(
          self.class.parent.outgoing_path,
          batch_file_name
        )
        file_body = begin
          if @transaction_type == WireClient::TransactionTypes::Credit
            @payment_inititation.to_xml('pain.001.001.03').to_s
          else
            @payment_inititation.to_xml('pain.008.001.02').to_s
          end
        end
        self.class.parent.write_remote_file(
          file_path: file_path,
          file_body: file_body
        )
        [file_path, file_body]
      end
    end
  end
end
