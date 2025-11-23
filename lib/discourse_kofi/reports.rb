# frozen_string_literal: true

module ::DiscourseKofi
  class Reports
    def self.payments(report)
      report.modes = [Report::MODES[:stacked_chart]]

      payments = self.base_payment_report(report)
      payments.each do |payment|
        payment[:data] = payment[:data].count.map do |timestamp, count|
          { x: timestamp, y: count }
        end
      end

      report.data = payments
    end

    def self.payment_amount(report)
      report.modes = [Report::MODES[:stacked_chart]]

      payments = self.base_payment_report(report)
      payments.each do |payment|
        payment[:data] = payment[:data]
          .sum(:amount)
          .map { |timestamp, amount| { x: timestamp, y: amount } }
      end

      report.data = payments
    end

    private

    def self.base_payment_report(report)
      Payment::PAYMENT_TYPES.keys.map do |filter|
        color = report.colors[:purple]
        color = report.colors[:lime] if filter == :subscription
        color = report.colors[:magenta] if filter == :commission
        color = report.colors[:yellow] if filter == :shop_order

        {
          req: filter,
          label: I18n.t("kofi.payment_type.#{filter}"),
          color: color,
          data:
            Payment
              .where(payment_type: filter)
              .where(
                "timestamp >= ? AND timestamp <= ?",
                report.start_date,
                report.end_date
              )
              .group("DATE(timestamp)")
              .order("DATE(timestamp)")
        }
      end
    end
  end
end
