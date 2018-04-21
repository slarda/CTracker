ActiveAdmin.register PlayerResult do
  permit_params :player_id, :game_id, :goals, :own_goals, :subst_on, :subst_off, :sport

  index do
    selectable_column
    id_column
    column :sport
    column :player
    column :game
    column :goals
    column :own_goals
    column :subst_on
    column :subst_off
    column :created_at
    actions
  end

  filter :sport
  filter :player_id, label: 'Player ID'
  filter :game_id, label: 'Game ID'
  filter :goals
  filter :own_goals
  filter :subst_on
  filter :subst_off
  filter :created_at

  form do |f|
    f.inputs 'Player Result Details' do
      f.input :sport
      f.input :player_id
      f.input :game_id
      f.input :goals
      f.input :own_goals
      f.input :subst_on
      f.input :subst_off
    end
    f.actions
  end

end
