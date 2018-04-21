class AddLogoToAssociation < ActiveRecord::Migration
  def change
    add_column :associations, :logo, :string
  end
end
