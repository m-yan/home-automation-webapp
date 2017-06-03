class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.references :event, index: true
      t.references :device, index: true
      t.references :operation_type, index: true

      t.timestamps null: false
    end
  end
end
