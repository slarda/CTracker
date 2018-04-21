class ChangeGeolocationToDecimal < ActiveRecord::Migration
  def up
    change_column :contact_details, :latitude, :decimal, precision: 15, scale: 10
    change_column :contact_details, :longitude, :decimal, precision: 15, scale: 10
  end

  def down
    change_column :contact_details, :latitude, :float
    change_column :contact_details, :longitude, :float
  end
end
