# frozen_string_literal: true

RSpec.describe DiscourseKofi::Reward, type: :model do
  let(:badge) { Fabricate(:badge) }
  let(:group) { Fabricate(:group) }

  it "save a subscription" do
    reward = ::DiscourseKofi::Reward.new
    reward.subscription = true
    reward.tier_name = "test"
    reward.group = group

    expect(reward.valid?).to be true
    expect(reward.save).to be true
  end

  it "subscription must have a group" do
    reward = ::DiscourseKofi::Reward.new
    reward.subscription = true
    reward.badge = badge

    expect(reward.valid?).to be false
    expect(reward.errors[:group]).to eq ["can't be blank"]
    expect(reward.errors[:badge]).to eq ["must be blank"]
  end

  it "subscription must have tier" do
    reward = ::DiscourseKofi::Reward.new
    reward.subscription = true
    reward.group = group

    expect(reward.valid?).to be false
    expect(reward.errors[:tier_name]).to eq ["can't be blank"]
  end

  it "subscription does not have payment types" do
    reward = ::DiscourseKofi::Reward.new
    reward.subscription = true
    reward.group = group
    reward.tier_name = "test"
    reward.payment_types = [:donation]

    expect(reward.valid?).to be false
    expect(reward.errors[:payment_types]).to eq ["must be blank"]
  end

  it "subscription does not have an amount" do
    reward = ::DiscourseKofi::Reward.new
    reward.subscription = true
    reward.group = group
    reward.tier_name = "test"
    reward.amount = 123.45

    expect(reward.valid?).to be false
    expect(reward.errors[:amount]).to eq ["must be blank"]
  end

  it "save a single reward" do
    reward = ::DiscourseKofi::Reward.new
    reward.group = group
    reward.badge = badge
    reward.amount = 123.45
    reward.payment_types = [:donation]

    expect(reward.valid?).to be true
    expect(reward.save).to be true
  end

  it "must have either a group or a badge" do
    reward = ::DiscourseKofi::Reward.new
    reward.amount = 123.45
    reward.payment_types = [:donation]

    expect(reward.valid?).to be false
    expect(reward.errors[:group]).to eq ["can't be blank"]
    expect(reward.errors[:badge]).to eq ["can't be blank"]

    reward.badge = badge
    expect(reward.valid?).to be true

    reward.badge = nil
    reward.group = group
    expect(reward.valid?).to be true
  end

  it "must be a valid payment type" do
    reward = ::DiscourseKofi::Reward.new
    reward.badge = badge
    reward.amount = 123.45
    reward.payment_types = %i[donation invalid_type]

    expect(reward.valid?).to be false
    expect(reward.errors[:payment_types]).to eq [
         "'invalid_type' is not a valid payment type"
       ]
  end

  it "must have at least one payment type" do
    reward = ::DiscourseKofi::Reward.new
    reward.badge = badge
    reward.amount = 123.45
    reward.payment_types = %i[]

    expect(reward.valid?).to be false
    expect(reward.errors[:payment_types]).to eq ["can't be blank"]
  end

  it "donation types is an array" do
    reward = ::DiscourseKofi::Reward.new
    reward.badge = badge
    reward.amount = 123.45
    reward.payment_types = {}

    expect(reward.valid?).to be false
    expect(reward.errors[:payment_types]).to eq ["must be an array"]
  end

  it "must have a positive amount" do
    reward = ::DiscourseKofi::Reward.new
    reward.badge = badge
    reward.payment_types = [:donation]

    expect(reward.valid?).to be false
    expect(reward.errors[:amount]).to eq ["is not a number"]

    reward.amount = -1
    expect(reward.valid?).to be false
    expect(reward.errors[:amount]).to eq ["must be greater than or equal to 0"]
  end

  it "must does not have a tier" do
    reward = ::DiscourseKofi::Reward.new
    reward.badge = badge
    reward.amount = 123.45
    reward.payment_types = [:donation]
    reward.tier_name = "test"

    expect(reward.valid?).to be false
    expect(reward.errors[:tier_name]).to eq ["must be blank"]
  end

  it "will have the badge set to nil when the badge is deleted" do
    reward = DiscourseKofi::Reward.new
    reward.badge = badge
    reward.amount = 123.45
    reward.payment_types = [:donation]
    reward.save!

    badge.destroy!

    reloaded = DiscourseKofi::Reward.find_by_id(reward.id)
    expect(reloaded.badge).to be_nil
  end

  it "will have the group set to nil when the group is deleted" do
    reward = DiscourseKofi::Reward.new
    reward.group = group
    reward.amount = 123.45
    reward.payment_types = [:donation]
    reward.save!

    group.destroy!

    reloaded = DiscourseKofi::Reward.find_by_id(reward.id)
    expect(reloaded.group).to be_nil
  end
end
