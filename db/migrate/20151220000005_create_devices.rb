class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.references :house, type: :string, index: true
      t.references :room, index: true
      t.string :note
      t.string :id_at_hgw, index: true
      t.string :type, index: true

      t.timestamps null: false
    end
  end
end
