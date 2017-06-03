class CreateOperationTypes < ActiveRecord::Migration
  def change
    create_table :operation_types do |t|
      t.string :description
      t.string :device_type, index: true
      t.string :method
      t.text :modules_body

      t.timestamps null: false
    end
  end
end
