class AddSportToAssociation < ActiveRecord::Migration
  def change
    add_column :associations, :sport, :string, default: 'soccer', nullable: false
  end
end
