# frozen_string_literal: true

RSpec.describe DiscourseKofi::PaymentStats do
  describe "leaderboard" do
    let(:account) { Fabricate(:kofi_account) }

    before(:example) do
      SiteSetting.kofi_leaderboard_count = 10
      SiteSetting.kofi_leaderboard_days = 30
      SiteSetting.kofi_leaderboard_types = "donation|commission"
    end

    it "is empty on zero size" do
      SiteSetting.kofi_leaderboard_count = 0
      leaderboard = described_class.calculate_leaderboard
      expect(leaderboard).to match_array([])
    end

    it "is empty on 0 days" do
      SiteSetting.kofi_leaderboard_days = 0
      leaderboard = described_class.calculate_leaderboard
      expect(leaderboard).to match_array([])
    end

    it "is empty on no types" do
      SiteSetting.kofi_leaderboard_types = ""
      leaderboard = described_class.calculate_leaderboard
      expect(leaderboard).to match_array([])
    end

    it "is populated" do
      Fabricate(
        :kofi_payment,
        amount: 100,
        from_name: "number1",
        email: "number1@FOO.test"
      )
      Fabricate(
        :kofi_payment,
        amount: 100,
        from_name: "number1",
        email: "number1@foo.test"
      )
      Fabricate(:kofi_payment, amount: 100, account: account)
      # excluded because payment too old
      Fabricate(
        :kofi_payment,
        amount: 500,
        account: account,
        timestamp: DateTime.now - 6.months
      )
      Fabricate(
        :kofi_payment,
        amount: 90,
        from_name: "number3 not public",
        is_public: false,
        email: "number3@foo.test"
      )
      Fabricate(
        :kofi_payment,
        amount: 1,
        from_name: "number3",
        email: "number3@foo.test"
      )
      Fabricate(:kofi_payment, amount: 80, from_name: "number4")
      # excluded because a subscription payment
      Fabricate(:kofi_subscription, amount: 1000)

      leaderboard = described_class.calculate_leaderboard

      expect(leaderboard).to eq(
        [
          { name: "number1" },
          { user_id: account.user.id },
          { anonymous: true },
          { name: "number4" }
        ]
      )
    end
  end
end
