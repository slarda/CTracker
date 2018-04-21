ActiveAdmin.register Game do
  permit_params :ref, :start_date, :end_date, :state, :association_id, :home_team_id, :away_team_id, :home_team_score,
                :away_team_score, :sport, :season, :venue_id

  index do
    selectable_column
    id_column
    column :ref
    column :sport
    column :season
    column :start_date
    column :home_team do |game|
      link_to("#{game.home_team.name} - #{game.home_team.club.name}", admin_team_path(game.home_team))
    end
    column :away_team do |game|
      link_to("#{game.away_team.name} - #{game.away_team.club.name}", admin_team_path(game.away_team))
    end
    column :home_team_score
    column :away_team_score
    actions
  end

  filter :ref
  filter :sport
  filter :season
  filter :start_date
  filter :end_date
  filter :state, as: :select, collection: Game.states
  filter :assoc
  filter :home_team_id, label: 'Home Team ID'
  filter :away_team_id, label: 'Away Team ID'
  filter :venue, label: 'Venue ID'
  filter :home_team_score
  filter :away_team_score

  form do |f|
    f.inputs 'Game Details' do
      f.input :ref
      f.input :sport
      f.input :season
      f.input :start_date
      f.input :end_date
      f.input :round
      f.input :round_str
      f.input :state, as: :select, collection: Game.states.keys
      f.input :assoc
      f.input :home_team, as: :select, collection: Team.all.sort_by{|x| x.club.try(:name) || x.name },
              member_label: Proc.new { |t| "#{t.club.try(:name)} - #{t.name}" }
      f.input :away_team, as: :select, collection: Team.all.sort_by{|x| x.club.try(:name) || x.name },
              member_label: Proc.new { |t| "#{t.club.try(:name)} - #{t.name}" }
      f.input :venue, as: :select, collection: ContactDetail.all.sort_by{|v| v.try(:full_address) },
              member_label: Proc.new { |v| v.try(:full_address) }
      f.input :home_team_score
      f.input :away_team_score
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :ref
      row :start_date
      row :end_date
      row :round
      row :round_str
      row :sport
      row :season
      row :state
      row :assoc
      row :home_team do |game|
        link_to("#{game.home_team.name} - #{game.home_team.club.name}", admin_team_path(game.home_team))
      end
      row :away_team do |game|
        link_to("#{game.away_team.name} - #{game.away_team.club.name}", admin_team_path(game.away_team))
      end
      row :venue
      row :home_team_score
      row :away_team_score
      row :specialized
      row :created_at
      row :updated_at
    end
  end
end
