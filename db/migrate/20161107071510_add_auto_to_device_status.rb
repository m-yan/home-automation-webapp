class AddAutoToDeviceStatus < ActiveRecord::Migration
  def up
    add_column :device_statuses, :auto, :boolean, default: false
    add_column :device_statuses, :auto_job_id, :string
  end
  def down
    remove_column :device_statuses, :auto
    remove_column :device_statuses, :auto_job_id
  end
end
