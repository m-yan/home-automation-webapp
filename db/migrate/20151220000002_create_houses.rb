class CreateHouses < ActiveRecord::Migration
  def change
    create_table :houses, id: false do |t|
      t.string :hgw_id, null: false
      t.string :name
      t.string :ip_address

      t.timestamps null: false
    end
    add_index :houses, :hgw_id, unique: true
  end
end
