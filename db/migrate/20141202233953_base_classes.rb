class BaseClasses < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email,                              null: false
      t.binary :crypted_password,                   null: true # Must be nullable for external (Oauth) authentication
      t.string :salt,                               null: true # Must be nullable for external (Oauth) authentication
      t.string :remember_me_token,                  default: nil
      t.datetime :remember_me_token_expires_at,     default: nil
      t.string :reset_password_token,               default: nil
      t.datetime :reset_password_token_expires_at,  default: nil
      t.datetime :reset_password_email_sent_at,     default: nil
      t.string :activation_state,                   default: nil
      t.string :activation_token,                   default: nil
      t.datetime :activation_token_expires_at,      default: nil

      t.string      :first_name,                    default: nil
      t.string      :middle_name,                   default: nil
      t.string      :last_name,                     default: nil
      t.string      :nickname,                      default: nil
      t.date        :dob,                           default: nil
      t.integer     :gender,                        default: 0, null: false
      t.string      :nationality,                   default: nil
      t.integer     :role,                          default: 0, null: false
      t.boolean     :agree_terms,                   null: false, default: false
      t.string      :position
      t.string      :avatar
      t.datetime    :team_changed_at
      t.integer     :verified,                      default: 0, null: false
      t.references  :team
      t.references  :club
      t.references  :association

      t.timestamps                null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :remember_me_token
    add_index :users, :reset_password_token
    add_index :users, :activation_token

    create_table :authentications do |t|
      t.integer :user_id, null: false
      t.string :provider, :uid, null: false
      t.timestamps                null: false
    end

    # rails g migration CreateAssociations name:string description:text url:string location:string
    create_table :associations do |t|
      t.string :name
      t.text :description
      t.string :url
      t.string :location
      t.timestamps                null: false
    end

    # rails g migration CreateClubs name:string description:text association:references
    create_table :clubs do |t|
      t.string :name
      t.text :description
      t.string :logo
      t.string :facebook
      t.string :twitter
      t.string :google_plus

      t.references :association, index: true
      t.timestamps                null: false
    end

    # rails g migration CreateTeams name:string description:text location:string association:references club:references
    create_table :teams do |t|
      t.string :name
      t.text :description
      t.string :location
      t.integer :year,              default: 0, null: false
      t.references :parent,         index: true
      t.references :association,    index: true
      t.references :club,           index: true
      t.references :division,       index: true
      t.timestamps                  null: false

      #t.integer :level,             default: 0, null: false
    end

    # rails g migration CreatePlayerProfiles user:references
    create_table :player_profiles do |t|
      t.references :user
      t.float :height_ft
      t.float :height_in
      t.float :height_cm
      t.float :weight_kg
      t.string :player_no
      t.integer :handedness
      t.text :biography
      t.text :specialized
      t.timestamps                null: false
    end

    # rails g delayed_job:active_record
    create_table :delayed_jobs, :force => true do |table|
      table.integer :priority, default: 0, null: false        # Allows some jobs to jump to the front of the queue
      table.integer :attempts, default: 0, null: false        # Provides for retries, but still fail eventually.
      table.text :handler, null: false                        # YAML-encoded string of the object that will do work
      table.text :last_error                                  # reason for last failure (See Note below)
      table.datetime :run_at                                  # When to run. Could be Time.zone.now for immediately, or sometime in the future.
      table.datetime :locked_at                               # Set when a client is working on this object
      table.datetime :failed_at                               # Set when all retries have failed (actually, by default, the record is deleted instead)
      table.string :locked_by                                 # Who is working on this object (if locked)
      table.string :queue                                     # The name of the queue this job is in
      table.timestamps                null: false
    end
    add_index :delayed_jobs, [:priority, :run_at], name: 'delayed_jobs_priority'

    #rails g migration CreateContactDetails address1:string address2:string address3:string suburb:string state:string
    # zipcode:string country:string phone1:string phone2:string phone3:string parent:references
    create_table :contact_details do |t|
      t.string :address1
      t.string :address2
      t.string :address3
      t.string :suburb
      t.string :state
      t.string :zipcode
      t.string :country
      t.string :phone1
      t.string :phone2
      t.string :phone3
      t.string :email
      t.string :website
      t.float :latitude
      t.float :longitude
      t.string :google_id
      t.references :parent, polymorphic: true, index: true
      t.timestamps                null: false
    end

    #rails g migration CreateGame ref:string start_date:datetime end_date:datetime round:integer venue:references
    # home_team:references away_team:references home_team_score:integer away_team_score:integer
    create_table :games do |t|
      t.string :ref,              unique: true, index: true
      t.datetime :start_date
      t.datetime :end_date
      t.integer :round
      t.integer :state
      t.references :association,  index: true
      t.references :home_team,    index: true
      t.references :away_team,    index: true
      t.references :venue,        index: true
      t.integer :home_team_score
      t.integer :away_team_score
      t.text :specialized
      t.timestamps                null: false
    end

    # rails g migration CreatePlayerResult goals:integer own_goals:integer subst_on:integer subst_off:integer
    create_table :player_results do |t|
      t.boolean :played_game
      t.string :sport
      t.integer :goals,           default: 0, null: false
      t.integer :own_goals,       default: 0, null: false
      t.integer :subst_on,        default: 0, null: false
      t.integer :subst_off,       default: 0, null: false
      t.integer :home_or_away,    default: 0, null: false
      t.integer :minutes_played,  default: 0, null: false
      t.text :specialized
      t.references :player,       index: true
      t.references :game,         index: true
      t.references :team,         index: true
      t.timestamps                null: false
    end
    add_foreign_key :player_results, :users, column: 'player_id'
    add_foreign_key :player_results, :games
    add_foreign_key :player_results, :teams

    # rails g migration CreateDivisions name:string description:text association:references
    create_table :divisions do |t|
      t.string :name
      t.text :description
      t.references :association, index: true
      t.timestamps                null: false
    end

    # rails g migration CreatePosition position:string sport:string
    create_table :positions do |t|
      t.string :position
      t.string :sport
      t.timestamps                null: false
    end

    # rails g migration CreatePlayerPositions position:references user:references
    create_table :player_positions do |t|
      t.references :position, index: true
      t.references :user, index: true
    end
    add_foreign_key :player_positions, :positions
    add_foreign_key :player_positions, :users

    # rails g migration CreateEquipment brand:string model:string equipment_type:integer specialized:text variations:text
    create_table :equipment do |t|
      t.string :brand
      t.string :model
      t.integer :equipment_type
      t.text :specialized
      t.text :variations
      t.timestamps                null: false
    end

    # rails g migration CreatePlayerEquipment brand:string model:string equipment_type:integer specialized:text colour:string equipment:references
    create_table :player_equipments do |t|
      t.references :user,         index: true
      t.string :brand
      t.string :model
      t.integer :equipment_type
      t.text :specialized
      t.string :colour
      t.references :equipment,    index: true
      t.timestamps                null: false
    end
    add_foreign_key :player_equipments, :equipment
  end
end