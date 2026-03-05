# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 Michiel Hendriks
# frozen_string_literal: true

RSpec.describe DiscourseKofi::DashboardController do
  fab!(:payment1) { Fabricate(:kofi_payment, amount: 30) }
  fab!(:account, :kofi_account)
  fab!(:payment2) { Fabricate(:kofi_payment, amount: 40, account: account) }

  before do
    SiteSetting.kofi_enabled = true
    SiteSetting.kofi_dashboard_enabled = true
    SiteSetting.kofi_goal_amount = 100

    ::DiscourseKofi::PaymentStats.calculate_leaderboard
    ::DiscourseKofi::PaymentStats.calculate_goal
  end

  describe "#index" do
    it "returns the dashboard" do
      get "/ko-fi/dashboard"
      expect(response.status).to eq(200)
      parsed = response.parsed_body

      expect(parsed[:goal][:progress]).to eq(70)

      expect(parsed[:leaderboard]).to contain_exactly(
        { user: include(id: account.user.id) },
        { name: payment1.from_name }
      )
    end

    it "returns nothing if disabled" do
      SiteSetting.kofi_dashboard_enabled = false
      get "/ko-fi/dashboard"
      expect(response.status).to eq(404)
    end
  end
end
