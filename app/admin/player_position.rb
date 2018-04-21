ActiveAdmin.register PlayerPosition do
  permit_params :position_id, :user_id

  index do
    selectable_column
    id_column
    column :position do |player_position|
      link_to player_position.position.position, admin_position_path(player_position.position)
    end
    column :user
    column :created_at
    actions
  end

  filter :position_id
  filter :user_id
  filter :created_at

  form do |f|
    f.inputs 'Player Position Details' do
      f.input :position_id
      f.input :user_id
    end
    f.actions
  end

end
