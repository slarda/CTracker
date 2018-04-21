class AddActiveSportToUser < ActiveRecord::Migration
  def up
    add_column :users, :active_sport, :string, default: 'soccer', nullable: false

    create_table :sport_profiles do |t|
      t.string :sport, default: 'soccer', nullable: false
      t.string :position
      t.string :player_no
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end

    User.all.each do |user|
      user.sport_profiles.create!(sport: 'soccer', position: user.positions.first.try(:position), player_no: user.player_profile.try(:player_no))
    end
  end

  def down
    drop_table :sport_profiles
    remove_column :users, :active_sport
  end
end
