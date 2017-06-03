class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.references :house, type: :string, index: true
      t.string :floor
      t.string :facility_type
      t.string :note

      t.timestamps null: false
    end
  end
end
