# frozen_string_literal: true

module ::DiscourseKofi
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DiscourseKofi
  end
end
