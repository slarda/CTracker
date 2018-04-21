class AddRolesToPosition < ActiveRecord::Migration
  def up
    add_column :positions, :roles, :string

    coach = Position.where(position: 'Coach', sport: 'soccer').first_or_create!
    coach.update_attribute(:roles, 'coach')
    Position.where(position: 'Assistant Coach', sport: 'soccer').first_or_create!(roles: 'coach')
  end

  def down
    remove_column :positions, :roles, :string
  end
end
