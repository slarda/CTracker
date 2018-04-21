ActiveAdmin.register Equipment do
  permit_params :brand_id, :model, :equipment_type, :specialized_as_yaml, :variations_as_yaml, equipment_photos_attributes: [:id, :photo, :_destroy]

  index do
    selectable_column
    id_column
    column :brand
    column :model
    column :equipment_type
    column :specialized
    column :variations
    column :created_at
    actions
  end

  filter :brand
  filter :model
  filter :equipment_type
  filter :specialized
  filter :variations
  filter :created_at

  form do |f|
    f.inputs 'Equipment Details' do
      f.input :brand
      f.input :model
      f.input :equipment_type, as: :select, collection: Equipment.equipment_types.keys
      f.input :specialized_as_yaml, as: :text
      f.input :variations_as_yaml, as: :text
      f.has_many :equipment_photos do |i|
        i.input :photo, as: :file, hint: image_tag(i.object.photo.url)
        i.input :_destroy, :as => :boolean
      end
    end
    f.actions
  end

  show do |equipment|
    attributes_table do
      row :id
      row :brand
      row :model
      row :equipment_type
      row :specialized
      row :variations
      row :created_at
      row :updated_at

      panel 'Photos' do
        equipment.equipment_photos.each do |photo|
          img(src: photo.photo.thumb.url)
        end
      end
    end
  end
end
