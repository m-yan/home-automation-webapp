class CreateRemoteButtons < ActiveRecord::Migration
  def change
    create_table :remote_buttons do |t|
      t.string :note

      t.timestamps null: false
    end
  end
end
