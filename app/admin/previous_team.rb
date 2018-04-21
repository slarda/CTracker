ActiveAdmin.register PreviousTeam do
  permit_params :user_id, :team_id

  index do
    selectable_column
    id_column
    column :user
    column :team
    column :created_at
    actions
  end

  filter :user_id
  filter :team_id
  filter :created_at

  form do |f|
    f.inputs 'Previous Team Details' do
      f.input :user
      f.input :team
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :user
      row :team
      row :created_at
      row :updated_at
    end
  end

end
