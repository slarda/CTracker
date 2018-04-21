class AddSnapchatToUser < ActiveRecord::Migration
  def change
    add_column :users, :snapchat, :string
  end
end
