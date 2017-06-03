class ChangeColumnsToDeviceStatuses < ActiveRecord::Migration
  def up
    remove_column :device_statuses, :on_timer
    remove_column :device_statuses, :off_timer
    add_column :device_statuses, :on_timer, :integer, default: 2
    add_column :device_statuses, :off_timer, :integer, default: 2
    change_column_default :device_statuses, :start_time, '2000-1-1T00:00:00.000+09:00'
    change_column_default :device_statuses, :stop_time, '2000-1-1T00:00:00.000+09:00'
    add_column :device_statuses, :start_time_relative, :integer    
    add_column :device_statuses, :stop_time_relative, :integer    
  end

  def down
    remove_column :device_statuses, :on_timer
    remove_column :device_statuses, :off_timer
    add_column :device_statuses, :on_timer, :boolean, default: false
    add_column :device_statuses, :off_timer, :boolean, default: false
    change_column_default :device_statuses, :start_time, nil
    change_column_default :device_statuses, :stop_time, nil
    remove_column :device_statuses, :start_time_relative
    remove_column :device_statuses, :stop_time_relative
  end 

end
