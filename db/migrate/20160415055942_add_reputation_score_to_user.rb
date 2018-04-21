class AddReputationScoreToUser < ActiveRecord::Migration
  def change
    add_column :users, :reputation_score, :integer, default: 0, null: false
  end
end
