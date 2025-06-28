# frozen_string_literal: true

RSpec.describe DiscourseKofi::SubscriptionRewardSerializer do
  let(:reward) { Fabricate(:subscription_reward) }

  it "contains reward details" do
    json =
      DiscourseKofi::SubscriptionRewardSerializer.new(
        reward,
        { root: false }
      ).as_json

    expect(json[:id]).not_to be_nil
    expect(json[:subscription]).to be true
    expect(json[:group]).not_to be_nil
    expect(json[:group][:id]).to eq reward.group.id
    expect(json[:group][:name]).to eq reward.group.name
    expect(json[:tier_name]).to eq reward.tier_name

    expect(json[:badge]).to be_nil
    expect(json[:payment_types]).to be_nil
    expect(json[:amount]).to be_nil
  end

  it "will not serialize a plain reward" do
    reward = Fabricate(:reward)
    expect {
      DiscourseKofi::SubscriptionRewardSerializer.new(reward).as_json
    }.to raise_error(ArgumentError, "Can only serialize subscription rewards")
  end
end
