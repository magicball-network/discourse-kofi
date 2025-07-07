# frozen_string_literal: true

require "csv"
require "date"
require "bigdecimal"

module DiscourseKofi
  class PaymentImporter
    def self.import_csv(csv_file, make_private = true)
      result = { payments: [], invalid_rows: [] }

      Payment.transaction do
        csv = CSV.open(csv_file, headers: true, skip_blanks: true)
        csv.each do |row|
          if row["TransactionId"].present?
            read_csv(csv.lineno, row, make_private, result)
          end
        end
      end

      result
    end

    private

    def self.read_csv(line_number, row, make_private, result)
      if Payment.exists?(kofi_transaction_id: row["TransactionId"])
        return error(result, line_number, "tx_already_known")
      end

      payment = Payment.new

      payment.timestamp = parse_date(row["DateTime (UTC)"])
      if payment.timestamp.blank?
        error(
          result,
          line_number,
          "invalid_datetime",
          datetime: row["DateTime (UTC)"]
        )
        return
      end

      payment.type = parse_type(row["TransactionType"])
      if payment.type.blank?
        error(result, line_number, "invalid_type", type: row["TransactionType"])
        return
      end

      payment.is_public = !make_private
      payment.from_name = row["From"]
      payment.message = row["Message"]
      payment.amount = parse_amount(row["Received"])

      if payment.amount.blank?
        error(result, line_number, "invalid_amount", amount: row["Received"])
        return
      elsif payment.amount <= 0
        return error(result, line_number, "zero_amount")
      end

      payment.currency = row["Currency"]
      payment.email = row["BuyerEmail"]
      payment.kofi_transaction_id = row["TransactionId"]
      if payment.test_transaction?
        return error(result, line_number, "test_transaction")
      end

      if payment.type_subscription?
        if row["Item"].blank?
          return error(result, line_number, "missing_tier_name")
        end
        payment.tier_name = row["Item"]
        payment.is_subscription_payment = true
        payment.is_first_subscription_payment = row["Reference"] != ""
      else
        payment.is_subscription_payment = false
        payment.is_first_subscription_payment = false
      end

      payment.message_id = generate_message_id(payment)

      unless payment.valid?
        result[:invalid_rows] << {
          line_number: line_number,
          message: payment.errors.join("\n")
        }
        return
      end
      payment.save
      result[:payments] << payment.id
    end

    def self.error(result, line_number, key, **args)
      result[:invalid_rows] << {
        line_number: line_number,
        message: I18n.t("kofi.payments.import.#{key}", **args)
      }
      nil
    end

    def self.parse_date(date_time_string)
      # 01/13/2025 12:56
      DateTime.strptime("#{date_time_string} +0000", "%m/%d/%Y %H:%M %z")
    rescue Date::Error
      nil
    end

    def self.parse_type(transaction_type)
      # TODO: shop order
      # TODO: commission
      case transaction_type
      when "Donation"
        "Donation"
      when "Monthly Donation"
        "Subscription"
      else
        nil
      end
    end

    def self.parse_amount(amount)
      BigDecimal(amount)
    rescue ArgumentError
      nil
    end

    def self.generate_message_id(payment)
      Digest::UUID.uuid_v5(
        "612e730c-2dd8-48da-a89c-49a7fb85d327",
        payment.kofi_transaction_id
      )
    end
  end
end
