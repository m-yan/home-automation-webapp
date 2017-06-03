class HsEventHandler
  
  def initialize(event)
    @event = event
  end

  def handle
    @event.operations.new(operation_type_id: HS_SIREN)
    @event.operations.new(operation_type_id: HS_NOTIFY_CENTER)
    @event.operations.new(operation_type_id: HS_NOTIFY_USER)

    NotificationHandler.send(@event.event_type_description)
    @event.house.users.each do |user|
      Notification.create(user: user, message: @event.event_type_description, detect_device: @event.device.name)
      NotificationMailer.email(user).deliver_later
    end
  end

end
