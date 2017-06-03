# == Schema Information
#
# Table name: device_statuses
#
#  id                  :integer          not null, primary key
#  device_id           :integer
#  type                :string
#  mode                :integer          default(1)
#  temperature         :float            default(25.0)
#  power               :boolean          default(FALSE)
#  volume              :integer          default(0)
#  start_time          :datetime         default(Sat, 01 Jan 2000 09:00:00 JST +09:00)
#  on_timer_job_id     :string
#  stop_time           :datetime         default(Sat, 01 Jan 2000 09:00:00 JST +09:00)
#  off_timer_job_id    :string
#  humidity            :integer          default(60)
#  opened              :integer          default(2)
#  enabled             :boolean          default(TRUE)
#  illuminance         :integer          default(1000)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  retry_job_id        :string
#  on_timer            :integer          default(2)
#  off_timer           :integer          default(2)
#  start_time_relative :integer
#  stop_time_relative  :integer
#  detected            :integer          default(2)
#  auto                :boolean          default(FALSE)
#  auto_job_id         :string
#
# Indexes
#
#  index_device_statuses_on_device_id  (device_id)
#

require 'sidekiq/api' 

class AirStatus < DeviceStatus

  validates :start_time, presence: true, time: true, if: "on_timer == 3"
  validates :stop_time, presence: true, time: true, if: "off_timer == 3"
  validates :start_time_relative, presence: true, numericality: { only_integer: true }, if: "on_timer == 4"
  validates :stop_time_relative, presence: true, numericality: { only_integer: true }, if: "off_timer == 4"
  validates :temperature, inclusion: {in: Range.new(18.0,31.0)}

  def raise_temperature(delta = 1)
    self.temperature += delta
    self.temperature = 31 if self.temperature > 31 
    return self.temperature
  end
   
  def lower_temperature(delta = 1)
    self.temperature -= delta 
    self.temperature = 18 if self.temperature < 18
    return self.temperature
  end

  def change_volume 
    case self.volume
    when 0..7 
      self.volume += 1 
    when 8
      self.volume = 0
    end
  end 

  def change_mode 
    case self.mode
    when 1..4
      self.mode += 1 
    when 5
      self.mode = 1
    end
  end

  def set_on_timer(time)
    self.on_timer = 3
    self.start_time = get_reservation_time time
    ActiveJobCanceller.cancel self.on_timer_job_id if self.on_timer_job_id
    job = AirOnTimerHandlerJob.set(wait_until: self.start_time).perform_later self    
    self.on_timer_job_id = job.job_id
  end

  def set_off_timer(time)
    self.off_timer = 3
    self.stop_time = get_reservation_time time
    ActiveJobCanceller.cancel self.off_timer_job_id if self.off_timer_job_id
    job = AirOffTimerHandlerJob.set(wait_until: self.stop_time).perform_later self
    self.off_timer_job_id = job.job_id
  end

  def set_on_timer_relative(time)
    self.on_timer = 4
    self.start_time_relative = time
    ActiveJobCanceller.cancel self.on_timer_job_id if self.on_timer_job_id
    job = AirOnTimerHandlerJob.set(wait: self.start_time_relative.minutes).perform_later self
    self.on_timer_job_id = job.job_id
  end

  def set_off_timer_relative(time)
    self.off_timer = 4
    self.stop_time_relative = time
    ActiveJobCanceller.cancel self.off_timer_job_id if self.off_timer_job_id
    job = AirOffTimerHandlerJob.set(wait: self.stop_time_relative.minutes).perform_later self
    self.off_timer_job_id = job.job_id
  end

  def cancel_on_timer
    self.on_timer = 2
    ActiveJobCanceller.cancel self.on_timer_job_id if self.on_timer_job_id
    self.on_timer_job_id = nil
    self.start_time_relative = nil
  end

  def cancel_off_timer
    self.off_timer = 2
    ActiveJobCanceller.cancel self.off_timer_job_id if self.off_timer_job_id
    self.off_timer_job_id = nil
    self.stop_time_relative = nil
  end

  def optimum_adjust_by environmenatal_info
    change_by environmenatal_info.determine_air_operating_area
  end

  private 
    
    def get_reservation_time(time_string)
      time = Time.zone.parse(time_string)
      if time.present? 
        date_string = time.strftime("%H:%M")
        time = Time.zone.parse date_string
        Time.current - time >= 0 ? time + 1.day : time 
      else
        nil
      end
    end

    def change_start_time_relative
      case self.start_time_relative
      when nil,60
        self.start_time_relative = 30
      when 30
        self.start_time_relative = 60
      end
    end

    def change_stop_time_relative
      case self.stop_time_relative
      when nil,60
        self.stop_time_relative = 30
      when 30
        self.stop_time_relative = 60
      end
    end

    def change_by area_id
      case area_id
      when 1
        self.power = true
        self.mode = 1
        self.temperature = 24
      when 2
        self.power = true
        self.mode = 1
        self.temperature = 23
      when 3
        self.power = true
        self.mode = 1
        self.temperature = 22
      when 4
        self.power = true
        self.mode = 1
        self.temperature = 22
      when 5
        self.power = true
        self.mode = 1
        self.temperature = 21
      when 6
        self.power = true
        self.mode = 1
        self.temperature = 20
      when 7
        self.power = true
        self.mode = 1
        self.temperature = 19
      when 8
        self.power = true
        self.mode = 4
      when 9
        self.power = false
      else
      end
    end

end
