ActiveAdmin.register User do
  permit_params :email, :password, :first_name, :last_name, :middle_name, :nickname,
                  :dob, :gender, :nationality, :role, :agree_terms, :verified, :position, :team_changed_at, :team,
                  :club, :assoc, :team_id, :club_id, :association_id, :facebook, :twitter, :google_plus,
                  :instagram, :linkedin, :youtube, :tumblr, :snapchat, :blog_url, :active_sport, :assoc_id,
                  :reputation_score

  index do
    selectable_column
    id_column
    column :email
    column 'Name' do |user|
      "#{user.first_name} #{user.last_name}"
    end
    column 'Status', :activation_state
    #column :role
    #column :agree_terms
    #column :position
    column :team
    column :club
    column 'Social' do |user|
      socials = []
      socials << user.facebook if user.facebook
      socials << user.twitter if user.twitter
      socials << user.google_plus if user.google_plus
      socials << user.instagram if user.instagram
      socials << user.linkedin if user.linkedin
      socials << user.youtube if user.youtube
      socials << user.tumblr if user.tumblr
      socials << user.snapchat if user.snapchat
      socials << user.blog_url if user.blog_url
      socials.join('<br>').html_safe
    end
    #column :assoc
    column 'Score', :reputation_score
    column :created_at
    actions do |user|
      item 'Impersonate', impersonate_user_path(user)
    end
  end

  batch_action :set_trustworthy do |ids|
    User.where(id: ids).update_all(reputation_score: 100)
    redirect_to admin_users_path, alert: 'Users have been given a reputation of 100'
  end

  batch_action :clear_trustworthy do |ids|
    User.where(id: ids).update_all(reputation_score: 0)
    redirect_to admin_users_path, alert: 'Users have had their trustworthiness reset to 0'
  end

  filter :email
  filter :first_name
  filter :middle_name
  filter :last_name
  filter :reputation_score
  filter :nickname
  filter :active_sport
  filter :dob
  filter :gender
  filter :nationality
  filter :activation_state
  filter :role
  filter :agree_terms
  filter :position
  filter :team_changed_at
  filter :team
  filter :club
  filter :assoc
  filter :created_at

  form do |f|
    f.inputs 'User Details' do
      f.input :email
      f.input :password
      #f.input :password_confirmation
      f.input :first_name
      f.input :last_name

      f.input :middle_name
      f.input :nickname
      f.input :reputation_score
      f.input :active_sport
      f.input :dob, start_year: 1950, end_year: DateTime.current.year
      f.input :gender, as: :select, collection: User.genders.keys
      f.input :nationality
      f.input :role, as: :select, collection: User.roles.keys
      f.input :agree_terms
      f.input :verified, as: :select, collection: User.verifieds.keys
      f.input :position
      f.input :team_changed_at
      f.input :team, as: :select, collection: Team.all.sort_by{|x| x.club.try(:name) || x.name },
                                  member_label: Proc.new { |t| "#{t.club.try(:name)} - #{t.name} - #{t.league.try(:name)}" }
      f.input :club, collection: Club.all.sort_by(&:name)
      f.input :assoc
      f.input :facebook
      f.input :twitter
      f.input :google_plus
      f.input :instagram
      f.input :linkedin
      f.input :youtube
      f.input :tumblr
      f.input :snapchat
      f.input :blog_url
      f.input :entered_club_name
      f.input :entered_team_name
      f.input :entered_league_name
      f.input :entered_website
      f.input :entered_additional_info
    end
    f.actions
  end

end
