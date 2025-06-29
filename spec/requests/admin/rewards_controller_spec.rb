# frozen_string_literal: true

RSpec.describe DiscourseKofi::Admin::RewardsController do
  fab!(:admin)

  before do
    SiteSetting.kofi_enabled = true
    sign_in(admin)
  end

  fab!(:reward)
  fab!(:subscription_reward)

  describe "#index" do
    it "returns all rewards" do
      get "/ko-fi/admin/rewards"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:rewards]).to contain_exactly(include(id: reward.id))
      expect(parsed[:subscriptions]).to contain_exactly(
        include(id: subscription_reward.id)
      )
    end
  end

  describe "#show" do
    it "returns a reward" do
      get "/ko-fi/admin/rewards/#{reward.id}"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:reward][:id]).to eq reward.id
      expect(parsed[:reward][:subscription]).to be false
      expect(parsed[:reward][:amount]).to eq reward.amount.as_json

      expect(parsed[:reward][:tier_name]).to be_nil
    end

    it "returns a subscription reward" do
      get "/ko-fi/admin/rewards/#{subscription_reward.id}"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:reward][:id]).to eq subscription_reward.id
      expect(parsed[:reward][:subscription]).to be true
      expect(parsed[:reward][:tier_name]).to eq subscription_reward.tier_name

      expect(parsed[:reward][:amount]).to be_nil
    end

    it "cannot find an unknown reward" do
      get "/ko-fi/admin/rewards/99999999999999999"
      expect(response.status).to eq(404)
    end
  end

  describe "#create" do
    fab!(:badge)
    fab!(:group)

    it "can create a new reward" do
      StaffActionLogger
        .any_instance
        .expects(:log_custom)
        .with("kofi_reward_creation", anything)
        .once

      post "/ko-fi/admin/rewards",
           params: {
             subscription: false,
             badge_id: badge.id,
             group_id: group.id,
             amount: 123.45,
             payment_types: %i[donation subscription]
           }

      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:reward][:id]).not_to be_nil
      expect(parsed[:reward][:subscription]).to be false
      expect(parsed[:reward][:badge][:id]).to eq badge.id
      expect(parsed[:reward][:group][:id]).to eq group.id
      expect(parsed[:reward][:amount]).to eq "123.45"
      expect(parsed[:reward][:payment_types]).to match_array(
        %w[donation subscription]
      )
    end

    it "can create a new subscription reward" do
      StaffActionLogger
        .any_instance
        .expects(:log_custom)
        .with("kofi_reward_creation", anything)
        .once

      post "/ko-fi/admin/rewards",
           params: {
             subscription: true,
             group_id: group.id,
             tier_name: "premium"
           }

      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:reward][:id]).not_to be_nil
      expect(parsed[:reward][:subscription]).to be true
      expect(parsed[:reward][:group][:id]).to eq group.id
      expect(parsed[:reward][:tier_name]).to eq "premium"
    end

    it "cannot create an invalid reward" do
      StaffActionLogger
        .any_instance
        .expects(:log_custom)
        .with("kofi_reward_creation", anything)
        .never

      post "/ko-fi/admin/rewards",
           params: {
             subscription: false,
             group_id: group.id,
             tier_name: "premium"
           }

      expect(response.status).to eq(422)
      parsed = response.parsed_body
      expect(parsed[:errors]).to match_array(
        [
          "Tier name must be blank",
          "Payment types can't be blank",
          "Amount is not a number",
          "Payment types must be an array"
        ]
      )
    end

    describe "#update" do
      it "can update a reward" do
        StaffActionLogger
          .any_instance
          .expects(:log_custom)
          .with("kofi_reward_change", anything)
          .once

        patch "/ko-fi/admin/rewards/#{reward.id}",
              params: {
                group_id: nil,
                amount: 123.45,
                payment_types: %w[donation subscription]
              }

        expect(response.status).to eq(200)
        parsed = response.parsed_body
        expect(parsed[:reward][:id]).to eq reward.id
        expect(parsed[:reward][:subscription]).to be false
        expect(parsed[:reward][:group]).to be_nil
        expect(parsed[:reward][:amount]).to eq "123.45"
        expect(parsed[:reward][:payment_types]).to match_array(
          %w[donation subscription]
        )
      end

      it "cannot change the subscription kind" do
        patch "/ko-fi/admin/rewards/#{reward.id}",
              params: {
                subscription: true
              }

        expect(response.status).to eq(200)
        parsed = response.parsed_body
        expect(parsed[:reward][:subscription]).to be false
      end

      it "cannot make invalid changes" do
        patch "/ko-fi/admin/rewards/#{reward.id}",
              params: {
                tier_name: "something"
              }

        expect(response.status).to eq(422)
      end

      it "cannot unpdate an unknown reward" do
        patch "/ko-fi/admin/rewards/9999999999999", params: {}

        expect(response.status).to eq(404)
      end
    end

    describe "#destroy" do
      it "can delete a reward" do
        StaffActionLogger
          .any_instance
          .expects(:log_custom)
          .with("kofi_reward_deletion", anything)
          .once

        delete "/ko-fi/admin/rewards/#{reward.id}"
        expect(response.status).to eq(200)

        get "/ko-fi/admin/rewards/#{reward.id}"
        expect(response.status).to eq(404)
      end

      it "cannot delete an unknown rewared" do
        delete "/ko-fi/admin/rewards/9999999999999"
        expect(response.status).to eq(404)
      end
    end
  end
end
