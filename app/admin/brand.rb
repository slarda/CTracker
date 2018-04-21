ActiveAdmin.register Brand do
  permit_params :name, :logo, :remove_logo

  index do
    selectable_column
    id_column
    column :name
    column :created_at
    actions
  end

  filter :name
  filter :created_at

  form(html: { multipart: true }) do |f|
    f.inputs 'Brand Details' do
      f.input :name
      f.input :logo, as: :file, hint: image_tag(f.object.logo.url)
      f.input :remove_logo, as: :boolean
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :created_at
      row :updated_at
      row :logo do |logo|
        img(src: logo.logo.thumb.url)
      end
    end
  end
end
