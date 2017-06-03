class AddJobIdToDeviceStatuses < ActiveRecord::Migration
  def up
    add_column :device_statuses, :retry_job_id, :string
  end

  def down
    remove_column :device_statuses, :retry_job_id
  end
end
