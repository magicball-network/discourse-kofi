# frozen_string_literal: true

module ::DiscourseKofi
  class BasicGroupSerializer < ApplicationSerializer
    attributes :id, :name, :url

    def name
      object.full_name || object.name
    end

    def url
      object.full_url
    end
  end
end
