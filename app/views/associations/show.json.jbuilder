json.extract! @association, :id, :name, :description, :location, :url
json.clubs @association.clubs
json.participants @association.participants, :id, :first_name, :last_name, :avatar_url
json.logo @association.logo
