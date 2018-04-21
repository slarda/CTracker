class CreateGameLink < ActiveRecord::Migration
  def change
    create_table :game_links do |t|
      t.references :user, index: true, foreign_key: true
      t.references :linked_to, polymorphic: true, index: true
      t.integer :kind, default: 0, null: false
      t.string :url
    end
  end
end
