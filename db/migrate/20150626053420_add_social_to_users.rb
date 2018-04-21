class AddSocialToUsers < ActiveRecord::Migration
  def change
    add_column :users, :instagram, :string
    add_column :users, :facebook, :string
    add_column :users, :twitter, :string
    add_column :users, :google_plus, :string
    add_column :users, :linkedin, :string
    add_column :users, :youtube, :string
    add_column :users, :tumblr, :string
    add_column :users, :blog_url, :string
  end
end
