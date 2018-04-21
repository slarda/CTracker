ActiveAdmin.register Position do
  permit_params :position, :sport, :roles

  index do
    selectable_column
    id_column
    column :position
    column :sport
    column :roles
    column :created_at
    actions
  end

  filter :position
  filter :sport
  filter :roles
  filter :created_at

  form do |f|
    f.inputs 'Position Details' do
      f.input :position
      f.input :sport
      f.input :roles
    end
    f.actions
  end

end
