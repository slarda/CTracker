class AddInstagramToClubs < ActiveRecord::Migration
  def change
    add_column :clubs, :instagram, :string
  end
end
