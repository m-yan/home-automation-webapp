class AirStatusLabel < ModelDecorator
  include ActionView::Helpers::TextHelper

  delegate :power, :mode, :temperature, :volume, :start_time, :stop_time, :on_timer, :off_timer, :start_time_relative, :stop_time_relative, to: :object, allow_nil: true

  def power_label
    power ? 'ON' : 'OFF'    
  end

  def mode_label
    case mode
    when 1
      return '自動'
    when 2
      return '冷房'
    when 3
      return '暖房'
    when 4
      return '除湿'
    when 5
      return '送風'
    when 6
      return 'その他'
    end
  end

  def volume_label
    case volume
    when 0
      return '自動'
    when 1
      return '風量1'
    when 2
      return '風量2'
    when 3
      return '風量3'
    when 4
      return '風量4'
    when 5
      return '風量5'
    when 6
      return '風量6'
    when 7
      return '風量7'
    when 8
      return '風量8'
    end
  end

  def start_time_label
    start_time ? start_time.strftime("%H:%M") : nil
  end

  def stop_time_label
    stop_time ? stop_time.strftime("%H:%M") : nil
  end

  def on_timer_label
    case on_timer
    when 2
      return  '予約なし'
    when 3
      return simple_format "予約あり\n( #{start_time.strftime("%H:%M")} )"
    when 4
      return simple_format "予約あり\n( #{start_time_relative}分後 )"
    end
  end

  def off_timer_label
    case off_timer
    when 2
      return  '予約なし'
    when 3
      return simple_format "予約あり\n( #{stop_time.strftime("%H:%M")} )"
    when 4
      return simple_format "予約あり\n( #{stop_time_relative}分後 )"
    end
  end

end
