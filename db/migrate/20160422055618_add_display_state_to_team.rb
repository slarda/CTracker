class AddDisplayStateToTeam < ActiveRecord::Migration
  def up
    add_column :teams, :display_state, :integer, default: 2
  end

  def down
    remove_column :teams, :display_state
  end
end
