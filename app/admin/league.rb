ActiveAdmin.register League do
  permit_params :name, :sport, :no_standings

  batch_action :remove_standings do |ids|
    League.where(id: ids).update_all(no_standings: true)
    redirect_to admin_leagues_path, alert: 'leagues have had their standings removed'
  end

  batch_action :add_standings do |ids|
    League.where(id: ids).update_all(no_standings: false)
    redirect_to admin_leagues_path, alert: 'leagues have had their standings re-instated'
  end

  index do
    selectable_column
    id_column
    column :name
    column :sport
    column "Teams" do |league|
      links = []
      league.teams.each do |team|
        links << link_to("#{team.name} - #{team.club.name}", admin_team_path(team))
      end
      links.join('<br>').html_safe
    end
    column :no_standings
    column :created_at
    actions
  end

  filter :name
  filter :sport
  filter :created_at
  filter :no_standings

  form do |f|
    f.inputs 'League Details' do
      f.input :name
      f.input :sport
      f.input :no_standings
    end
    f.actions
  end

end
