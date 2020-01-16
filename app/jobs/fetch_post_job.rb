class FetchPostJob < ApplicationJob
  queue_as :default

  def perform(posts)
  end
end
