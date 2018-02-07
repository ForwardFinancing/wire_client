require_relative './message'
require_relative '../transaction/credit_transfer_transaction'

module WireClient
  class CreditTransfer < Message
    self.account_class = DebtorAccount
    self.transaction_class = CreditTransferTransaction
    self.xml_main_tag = 'CstmrCdtTrfInitn'
    self.known_schemas = [WireClient::PAIN_001_001_03]

    private

    # Find groups of transactions which share the same values of some attributes
    def transaction_group(transaction)
      {
        requested_date:   transaction.requested_date,
        batch_booking:    transaction.batch_booking,
        service_priority: transaction.service_priority,
        service_level:    transaction.service_level
      }
    end

    def build_payment_informations(builder)
      # Build a PmtInf block for every group of transactions
      grouped_transactions.each do |group, transactions|
        # All transactions with the same requested_date are placed into the same PmtInf block
        builder.PmtInf do
          builder.PmtInfId(payment_information_identification(group))
          builder.PmtMtd('TRF')
          builder.BtchBookg(group[:batch_booking])
          builder.NbOfTxs(transactions.length)
          builder.CtrlSum('%.2f' % amount_total(transactions))
          builder.PmtTpInf do
            builder.InstrPrty(group[:service_priority])
            builder.SvcLvl do
              builder.Cd(group[:service_level])
            end
          end
          builder.ReqdExctnDt(group[:requested_date].iso8601)
          builder.Dbtr do
            builder.Nm(account.name)
            builder.PstlAdr do
              builder.CtrySubDvsn(account.country_subdivision_name)
              builder.Ctry(account.country)
            end
          end
          builder.DbtrAcct do
            builder.Id do
              account_id(builder, account)
            end
          end
          builder.DbtrAgt do
            builder.FinInstnId do
              account_agent_id(builder, account)
              builder.PstlAdr do
                builder.Ctry(account.country)
              end
            end
          end

          if account.charge_bearer
            builder.ChrgBr(account.charge_bearer)
          end

          transactions.each do |transaction|
            build_transaction(builder, transaction)
          end
        end
      end
    end

    def build_transaction(builder, transaction)
      builder.CdtTrfTxInf do
        builder.PmtId do
          if transaction.instruction.present?
            builder.InstrId(transaction.instruction)
          end
          builder.EndToEndId(transaction.reference)
        end
        builder.Amt do
          builder.InstdAmt('%.2f' % transaction.amount, Ccy: transaction.currency)
        end
        builder.CdtrAgt do
          builder.FinInstnId do
            transaction_agent_id(builder, transaction)
            builder.PstlAdr do
              builder.Ctry(transaction.country)
            end
          end
        end
        builder.Cdtr do
          builder.Nm(transaction.name)
          builder.PstlAdr do
            builder.Ctry(transaction.country)
          end
        end
        builder.CdtrAcct do
          builder.Id do
            transaction_account_id(builder, transaction)
          end
        end
        if transaction.remittance_information
          builder.RmtInf do
            builder.Ustrd(transaction.remittance_information)
          end
        end
      end
    end
  end
end
