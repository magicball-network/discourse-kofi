# frozen_string_literal: true

RSpec.describe DiscourseKofi::RewardSerializer do
  let(:reward) { Fabricate(:kofi_reward, group: Fabricate(:group)) }

  it "contains reward details" do
    json = DiscourseKofi::RewardSerializer.new(reward, { root: false }).as_json

    expect(json[:id]).not_to be_nil
    expect(json[:enabled]).to be true
    expect(json[:subscription]).to be false
    expect(json[:badge]).not_to be_nil
    expect(json[:badge][:id]).to eq reward.badge.id
    expect(json[:badge][:name]).to eq reward.badge.name
    expect(json[:group]).not_to be_nil
    expect(json[:group][:id]).to eq reward.group.id
    expect(json[:group][:name]).to eq reward.group.name
    expect(json[:payment_types]).to eq reward.payment_types
    expect(json[:amount]).to eq reward.amount

    expect(json[:tier_name]).to be_nil
  end

  it "will not serialize a subscription reward" do
    reward = Fabricate(:kofi_subscription_reward)
    expect {
      DiscourseKofi::RewardSerializer.new(reward).as_json
    }.to raise_error(ArgumentError, "Cannot serialize subscription rewards")
  end
end
