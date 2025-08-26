# frozen_string_literal: true

module DiscourseKofi
  class PaymentQueryBuilder
    ORDER_MAPPING = {
      "timestamp" => "timestamp",
      "type" => "payment_type",
      "tier" => "tier_name",
      "amount" => "amount"
    }

    attr_reader :query

    def initialize(params, pre_filter = {})
      @params = params
      @query = init_query(pre_filter)
    end

    def find_payments(limit = 50)
      page = @params[:page].to_i - 1
      page = 0 if page < 0
      query.limit(limit).offset(page * limit)
    end

    private

    def init_query(pre_filter)
      order = []

      custom_order = @params[:order]
      custom_direction = @params[:asc].present? ? "ASC" : "DESC"
      if custom_order.present? && order_directive = ORDER_MAPPING[custom_order]
        order << "#{order_directive} #{custom_direction} NULLS LAST"
      end

      if !custom_order.present?
        order << "timestamp desc" if !custom_order.present?
      end

      query = Payment.where(pre_filter).order(order.reject(&:blank?).join(","))

      query = add_search(query, @params[:search]) if @params[:search].present?
      query =
        add_period(query, @params[:startDate], @params[:endDate]) if @params[
        :startDate
      ].present?

      query
    end

    def add_search(query, search)
      search = search.strip.downcase
      return query if search.blank?
      query.left_joins(:user).where(
        "kofi_transaction_id = :search or from_name ilike :search_like or email ilike :search_like or users.username ilike :search_like",
        search: search,
        search_like: "%#{search}%"
      )
    end

    def add_period(query, start_date, end_date)
      start_date = DateTime.iso8601(start_date)
      if end_date.present?
        end_date = DateTime.iso8601(end_date)
      else
        end_date = DateTime.now
      end
      query.where(timestamp: start_date..end_date)
    end
  end
end
