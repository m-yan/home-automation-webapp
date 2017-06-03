class HsEventHandlerJob < ActiveJob::Base
  queue_as :default

  def perform(event)
    HsEventHandler.new(event).handle
    event.save
  end
end
