class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.references :house, type: :string, index: true
      t.references :user, index: true
      t.references :device, index: true
      t.references :event_type, index: true
      t.timestamp :occurred_at

      t.timestamps null: false
    end
  end
end
