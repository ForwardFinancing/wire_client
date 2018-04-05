require_relative './message'
require_relative '../transaction/direct_debit_transaction'

module WireClient
  class DirectDebit < Message
    self.account_class = CreditorAccount
    self.transaction_class = DirectDebitTransaction
    self.xml_main_tag = 'CstmrDrctDbtInitn'
    self.known_schemas = [WireClient::PAIN_008_001_02]

    validate do |record|
      if record.transactions.map(&:local_instrument).uniq.size > 1
        errors.add(
          :base,
          'CORE, COR1 and B2B must not be mixed in one message!'
        )
      end
    end

    private

    # Find groups of transactions which share the same values for
    # selected attributes
    def transaction_group(transaction)
      {
        requested_date:   transaction.requested_date,
        local_instrument: transaction.local_instrument,
        sequence_type:    transaction.sequence_type,
        batch_booking:    transaction.batch_booking,
        account:          transaction.creditor_account || account,
        service_priority: transaction.service_priority,
        service_level:    transaction.service_level
      }
    end

    def build_payment_information(builder)
      # Build a PmtInf block for every group of transactions
      grouped_transactions.each do |group, transactions|
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
            builder.LclInstrm do
              builder.Cd(group[:local_instrument])
            end
            builder.SeqTp(group[:sequence_type])
          end
          builder.ReqdColltnDt(group[:requested_date].iso8601)
          builder.Cdtr do
            builder.Nm(group[:account].name)
            builder.PstlAdr do
              entity_address(builder, account)
            end
          end
          builder.CdtrAcct do
            account_id(builder, group[:account])
          end
          builder.CdtrAgt do
            builder.FinInstnId do
              entity_agent_id(builder, group[:account])
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

    def build_amendment_informations(builder, transaction)
      return unless transaction.original_debtor_account ||
                    transaction.same_mandate_new_debtor_agent
      builder.AmdmntInd(true)
      builder.AmdmntInfDtls do
        if transaction.original_debtor_account
          builder.OrgnlDbtrAcct do
            builder.Id do
              builder.IBAN(transaction.original_debtor_account)
            end
          end
        else
          builder.OrgnlDbtrAgt do
            builder.FinInstnId do
              builder.Othr do
                builder.Id('SMNDA')
              end
            end
          end
        end
      end
    end

    def build_transaction(builder, transaction)
      builder.DrctDbtTxInf do
        builder.PmtId do
          if transaction.instruction.present?
            builder.InstrId(transaction.instruction)
          end
          builder.EndToEndId(transaction.reference)
        end
        builder.InstdAmt(
          '%.2f' % transaction.amount,
          Ccy: transaction.currency
        )
        builder.DrctDbtTx do
          builder.MndtRltdInf do
            builder.MndtId(transaction.mandate_id)
            builder.DtOfSgntr(transaction.mandate_date_of_signature.iso8601)
            build_amendment_informations(builder, transaction)
          end
        end
        builder.DbtrAgt do
          builder.FinInstnId do
            entity_agent_id(builder, transaction)
            builder.Nm(transaction.agent_name)
            builder.PstlAdr do
              entity_address(builder, transaction)
            end
          end
        end
        builder.Dbtr do
          builder.Nm(transaction.name)
        end
        builder.DbtrAcct do
          transaction_account_id(builder, transaction)
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
