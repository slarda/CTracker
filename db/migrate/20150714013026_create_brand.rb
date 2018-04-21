class CreateBrand < ActiveRecord::Migration

  def up
    remove_column :equipment, :brand
    add_reference :equipment, :brand
    create_table :brands do |t|
      t.string :name
      t.string :logo
      t.timestamps null: false
    end
  end

  def down
    drop_table :brands
    remove_column :equipment, :brand
    add_column :equipment, :brand, :string
  end
end
