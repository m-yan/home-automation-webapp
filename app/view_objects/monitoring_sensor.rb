class MonitoringSensor < ModelDecorator
  attr_accessor :mode
  delegate :id, :type, :room_id, :location, :enabled, :opened, :detected, to: :object, allow_nil: true

  def initialize(sensor, mode)
    super(sensor)
    @mode = mode
  end

  def sensed_state
    case self.type
    when  'OcSensor'
      self.opened == 1 ? true : false
    when 'MSensor'
      self.detected == 1 ? true : false
    end
  end 

  def monitoring_state
    return false unless self.enabled
    case @mode
    when 1
      return false
    when 2
      return self.type == 'OcSensor' ? true : false
    when 3
      return true
    end    
  end

end
