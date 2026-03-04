# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 Michiel Hendriks
# frozen_string_literal: true

module ::DiscourseKofi
  class AdminAccountSerializer < AccountSerializer
    attributes :email_hash, :anonymized
  end
end
