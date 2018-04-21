ActiveAdmin.register Award do

  permit_params :year, :award, :user_id, :team_id

  index do
    selectable_column
    id_column
    column :year
    column :team
    column :award
    column :created_at
    actions
  end

  filter :year
  filter :team
  filter :created_at

  form do |f|
    f.inputs 'Award Details' do
      f.input :year
      f.input :user
      f.input :team
      f.input :award
    end
    f.actions
  end


end
