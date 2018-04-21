ActiveAdmin.register Club do
  permit_params :name, :description, :facebook, :twitter, :twitter_widget, :google_plus, :instagram, :youtube, :association_id,
                  location_attributes: [:id, :address1, :address2, :address3, :suburb, :state, :zipcode, :country, :phone1, :phone2, :phone3,
                                        :longitude, :latitude, :website, :email, :google_id, :_destroy]

  index do
    selectable_column
    id_column
    column :name
    column 'Teams' do |club|
      links = []
      club.teams.each do |team|
        links << link_to("#{team.name} - #{team.league.try(:name)}", admin_team_path(team))
      end
      links.join('<br>').html_safe
    end
    column :location do |club|
      link_to club.location.full_address, admin_contact_detail_path(club.location.id) if club.location
    end
    column :social do |club|
      socials = []
      socials << club.facebook if club.facebook
      socials << club.twitter if club.twitter
      socials << club.google_plus if club.google_plus
      socials << club.instagram if club.instagram
      socials << club.youtube if club.youtube
      socials.join('<br>').html_safe
    end

    #column :created_at
    actions
  end

  filter :name
  filter :teams
  filter :location_id, label: 'Location ID'
  filter :facebook
  filter :twitter
  filter :google_plus
  filter :instagram
  filter :youtube
  filter :created_at

  form do |f|
    f.inputs 'Club Details' do
      f.input :name
      f.input :description
      f.input :assoc

      # TODO: Reverse polymorphic has_one association is not supported by Rails forms (select, select_tag) yet
      #f.input :location, as: :select

      f.input :facebook
      f.input :twitter
      f.input :twitter_widget
      f.input :google_plus
      f.input :instagram
      f.input :youtube

      f.inputs 'Location', for: [:location, f.object.location || ContactDetail.new ] do |location|
        location.input :address1
        location.input :address2
        location.input :address3
        location.input :suburb
        location.input :state
        location.input :zipcode
        location.input :country
        location.input :phone1
        location.input :phone2
        location.input :phone3
        location.input :email
        location.input :website
        location.input :latitude
        location.input :longitude
        location.input :google_id

        location.actions
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :logo
      row :facebook
      row :twitter
      row :twitter_widget
      row :google_plus
      row :instagram
      row :youtube
      row :association_id
      row :location

      row :teams do |club|
        links = []
        club.teams.each do |team|
          links << link_to(team.name, admin_team_path(team))
        end
        links.join('<br>').html_safe
      end

      row :created_at
      row :updated_at
    end
  end
end
