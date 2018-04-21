ActiveAdmin.register Article do
  permit_params :category, :url

  index do
    selectable_column
    id_column
    column :category
    column :url
    column :created_at
    actions
  end

  filter :category
  filter :created_at

  form do |f|
    f.input :category
    f.input :url
    f.actions
  end
end
