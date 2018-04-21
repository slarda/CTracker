json.extract! @club, :id, :name, :description, :facebook, :twitter, :twitter_widget, :google_plus, :instagram, :youtube
json.teams do
  filtered_teams = @filter_year ? @club.teams.where(year: @filter_year) : @club.teams
  teams = filtered_teams.includes(:league).order('leagues.name ASC, teams.name ASC')
  json.array!(teams) do |team|
    json.(team, :id, :name, :augmented_league_name)
    json.league do
      json.(team.league, :id, :name)
    end
  end
end
json.location do
  json.(@club.location, :id, :address1, :address2, :address3, :suburb, :state, :zipcode, :country, :full_address, :phone1, :phone2, :phone3,
                :email, :website, :latitude, :longitude, :google_id, :created_at, :updated_at) if @club.location
end
json.assoc do
  json.(@club.assoc, :id, :name, :description, :url, :location, :sport)
  json.logo @club.assoc.logo
end if @club.assoc
json.participants @club.participants, :id, :first_name, :last_name, :avatar_url
json.logo @club.logo
