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

class ISensorStatus < DeviceStatus
  validates :illuminance, presence: true
end
