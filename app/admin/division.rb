ActiveAdmin.register Division do
  permit_params :name, :description

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :created_at
    actions
  end

  filter :name
  filter :description
  filter :created_at

  form do |f|
    f.inputs 'Division Details' do
      f.input :name
      f.input :description
    end
    f.actions
  end

end
