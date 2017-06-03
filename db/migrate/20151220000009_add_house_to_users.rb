class AddHouseToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.references :house, type: :string, index: true
    end
  end

  def down
    remove_column :users, :house_id
  end
end
