ActiveAdmin.register PlayerProfile do
  permit_params :height_ft, :height_in, :height_cm, :weight_kg, :player_no, :handedness, :biography,
                :specialized

  index do
    selectable_column
    id_column
    column :height_cm
    column :weight_kg
    column :player_no
    column :handedness
    column :updated_at
    actions
  end

  filter :height_cm
  filter :weight_kg
  filter :player_no
  filter :handedness
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs 'Player Profile Details' do
      f.input :height_cm
      f.input :weight_kg
      f.input :player_no
      f.input :handedness
    end
    f.actions
  end

end
