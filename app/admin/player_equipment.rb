ActiveAdmin.register PlayerEquipment do
  permit_params :equipment_id, :user_id, :brand, :model, :equipment_type, :specialized, :colour

  index do
    selectable_column
    id_column
    column :equipment do |player_equipment|
      link_to "#{player_equipment.equipment.try(:brand)} - #{player_equipment.equipment.try(:model)}", admin_player_equipment_path(player_equipment.equipment) if player_equipment.equipment
    end
    column :user do |player_equipment|
      link_to player_equipment.player.full_name, admin_user_path(player_equipment.player)
    end
    column :brand
    column :model
    column :equipment_type
    column :colour
    column :created_at
    actions
  end

  filter :equipment_id
  filter :user_id
  filter :brand
  filter :model
  filter :equipment_type
  filter :specialized
  filter :colour
  filter :created_at

  form do |f|
    f.inputs 'Player Equipment Details' do
      f.input :equipment_id
      f.input :user_id
      f.input :brand
      f.input :model
      f.input :equipment_type, as: :select, collection: Equipment.equipment_types.keys
      f.input :specialized
      f.input :colour
    end
    f.actions
  end

end
