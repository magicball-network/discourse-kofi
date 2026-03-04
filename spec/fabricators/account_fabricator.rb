# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 Michiel Hendriks
# frozen_string_literal: true

require "faker"

Fabricator(:kofi_account, from: "DiscourseKofi::Account") do
  user
  email { Faker::Internet.email }
end
