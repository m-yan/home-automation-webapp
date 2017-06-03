class AddDectedToDeviceStatuses < ActiveRecord::Migration
  def up
    add_column :device_statuses, :detected, :integer, default: 2
  end

  def down
    remove_column :device_statuses, :detected
  end
end
