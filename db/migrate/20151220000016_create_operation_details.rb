class CreateOperationDetails < ActiveRecord::Migration
  def change
    create_table :operation_details do |t|
      t.references :operation, index: true
      t.string :uri
      t.string :method
      t.text :request
      t.string :result_status
      t.text :response

      t.timestamps null: false
    end
  end
end
