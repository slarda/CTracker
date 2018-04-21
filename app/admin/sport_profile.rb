ActiveAdmin.register SportProfile do
  permit_params :sport, :position, :player_no, :user

  index do
    selectable_column
    id_column

    column :sport
    column :position
    column :player_no
    column :user
    column :updated_at
    actions
  end

  filter :sport
  filter :position
  filter :player_no
  filter :user
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs 'Sport Profile Details' do
      f.input :sport
      f.input :position
      f.input :player_no
      f.input :user, as: :select, collection: User.all.sort_by{|x| x.try(:full_name) }
    end
    f.actions
  end

end
