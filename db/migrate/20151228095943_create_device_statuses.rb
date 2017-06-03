class CreateDeviceStatuses < ActiveRecord::Migration
  def change
    create_table :device_statuses do |t|
      t.references :device, index: true, foreign_key: true
      t.string :type
      
      #HGW、エアコン
      t.integer :mode, default: 1

      #エアコン、温湿度センサ
      t.float :temperature, default: 25.0

      #エアコン
      t.boolean :power, default: false
      t.integer :volume, default: 0
      t.boolean :on_timer, default: false
      t.timestamp :start_time
      t.string :on_timer_job_id
      t.boolean :off_timer, default: false
      t.timestamp :stop_time
      t.string :off_timer_job_id

      #温湿度センサ 
      t.integer :humidity, default: 60

      #開閉センサ
      t.integer :opened, default: 2
      t.boolean :enabled, default: true

      #照度センサ
      t.integer :illuminance, default: 1000

      t.timestamps null: false
    end
  end
end
