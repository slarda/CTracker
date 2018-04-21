class AddSuperAdminToUser < ActiveRecord::Migration
  def up
    add_column :users, :super_admin, :boolean, default: false, nullable: false
    con_harbis = User.where(email: 'conharbis@conharbis.com').first
    con_harbis.update_attribute(:super_admin, true) if con_harbis
  end

  def down
    remove_column :users, :super_admin
  end
end
