class CreateRemoteButtonsOperationTypesJoinTable < ActiveRecord::Migration
  def change
    create_join_table :remote_buttons, :operation_types do |t|
      t.integer :order
      t.index :remote_button_id
    end
  end
end
