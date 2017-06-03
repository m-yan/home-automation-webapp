class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true
      t.text :message
      t.string :detect_device
      t.boolean :read, default: false

      t.timestamps null: false
    end
  end
end
