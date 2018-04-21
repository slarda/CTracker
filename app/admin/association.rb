ActiveAdmin.register Association do
  permit_params :name, :description, :url, :location, :sport

  index do
    selectable_column
    id_column
    column :name
    column :sport
    column :url
    column :location
    column :created_at
    actions
  end

  filter :name
  filter :sport
  filter :location
  filter :created_at

  form do |f|
    f.inputs 'Association Details' do
      f.input :name
      f.input :description
      f.input :sport
      f.input :url
      f.input :location
    end
    f.actions
  end

end
