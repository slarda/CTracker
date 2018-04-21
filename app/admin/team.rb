ActiveAdmin.register Team do
  permit_params :name, :description, :location, :year, :club_id, :league_id, :league_count, :association_id, :display_state

  index do
    selectable_column
    id_column
    column :name
    column :club
    column :year
    column :league
    column :location
    column :display_state
    column :created_at
    actions
  end

  filter :name
  filter :club
  filter :year
  filter :league
  filter :location
  filter :description
  filter :display_state
  filter :created_at

  form do |f|
    f.inputs 'Team Details' do
      f.input :name
      f.input :club, collection: Club.order('name ASC').all
      f.input :year
      f.input :league, collection: League.order('name ASC').all
      f.input :league_count
      f.input :description
      f.input :location
      f.input :assoc
      f.input :display_state, as: :select, collection: Team.display_states.keys
    end
    f.actions
  end


  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :location
      row :parent
      row :assoc
      row :club
      row :year
      row :league
      row :division
      row :league_count
      row :display_state
      row :games do |team|
        links = []
        team.games.each do |game|
          links << link_to(game.start_date_s, admin_game_path(game))
        end
        links.join('<br>').html_safe
      end
      row :created_at
      row :updated_at
    end
  end

end
