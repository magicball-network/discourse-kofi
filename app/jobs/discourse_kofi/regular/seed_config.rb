# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 Michiel Hendriks
# frozen_string_literal: true

module ::DiscourseKofi::Jobs
  class SeedConfig < ::Jobs::Base
    cluster_concurrency 1
    sidekiq_options queue: "critical"

    def execute(args)
      DiscourseKofi::Seed.seed_me_seymour
    end
  end
end
