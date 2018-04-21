class CreateEquipmentPhoto < ActiveRecord::Migration
  def change
    create_table :equipment_photos do |t|
      t.string :photo
      t.references :equipment, index: true, foreign_key: true
    end
  end
end
