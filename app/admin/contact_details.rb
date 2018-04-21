ActiveAdmin.register ContactDetail do
  permit_params :address1, :address2, :address3, :suburb, :state, :zipcode, :country, :phone1, :phone2, :phone3,
                  :longitude, :latitude, :website, :email, :google_id


  index do
    selectable_column
    id_column
    column :full_address
    column :suburb
    column :country
    column :combined_phones
    actions
  end

  filter :address1
  filter :address2
  filter :address3
  filter :suburb
  filter :state
  filter :zipcode
  filter :country
  filter :phone1
  filter :phone2
  filter :phone3
  filter :email
  filter :website
  filter :created_at

  form do |f|
    f.inputs 'Contact / Venue Details' do
      f.input :address1
      f.input :address2
      f.input :address3
      f.input :suburb
      f.input :state
      f.input :zipcode
      f.input :country
      f.input :phone1
      f.input :phone2
      f.input :phone3
      f.input :email
      f.input :website
      f.input :latitude
      f.input :longitude
      f.input :google_id
    end
    f.actions
  end

end
