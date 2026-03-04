# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 Michiel Hendriks
# frozen_string_literal: true

def plugin_file_fixture(*path)
  File.new(
    Rails.root.join(
      "plugins",
      "discourse-kofi",
      "spec",
      "fixtures",
      "files",
      *path
    )
  )
end
