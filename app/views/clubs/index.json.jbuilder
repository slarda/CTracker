json.array! @clubs do |club|
  json.extract! club, :id, :name, :description
  #json.teams club.teams
  json.location club.location
  json.association_id club.association_id
  #json.participants club.participants, :id, :first_name, :last_name, :avatar_url
end
