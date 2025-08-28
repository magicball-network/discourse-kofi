# frozen_string_literal: true

module DiscourseKofi
  class AccountQueryBuilder
    ORDER_MAPPING = {
      "user" => "users.username",
      "created_at" => "created_at",
      "email" => "email"
    }

    attr_reader :query

    def initialize(params, pre_filter = {})
      @params = params
      @query = init_query(pre_filter)
    end

    def find_accounts(limit = 50)
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

      order << "created_at desc" if order.empty?

      query =
        Account
          .left_joins(:user)
          .where(pre_filter)
          .order(order.reject(&:blank?).join(","))
          .includes(:latest_payment)

      query = add_search(query, @params[:search]) if @params[:search].present?

      query
    end

    def add_search(query, search)
      search = search.strip.downcase
      return query if search.blank?
      query.where(
        "email ilike :search_like or users.username ilike :search_like",
        search_like: "%#{search}%"
      )
    end
  end
end
