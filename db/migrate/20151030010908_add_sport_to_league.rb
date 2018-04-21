class AddSportToLeague < ActiveRecord::Migration
  def change
    add_column :leagues, :sport, :string, default: 'soccer', nullable: false
  end
end
