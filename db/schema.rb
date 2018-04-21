# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171225181143) do

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "articles", force: :cascade do |t|
    t.string   "category",   limit: 255
    t.text     "url",        limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "associations", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.string   "url",         limit: 255
    t.string   "location",    limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "sport",       limit: 255,   default: "soccer"
    t.string   "logo",        limit: 255
  end

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id",    limit: 4,   null: false
    t.string   "provider",   limit: 255, null: false
    t.string   "uid",        limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "awards", force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "team_id", limit: 4
    t.string  "year",    limit: 255
    t.string  "award",   limit: 255
  end

  create_table "brands", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "logo",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "clubs", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.text     "description",    limit: 65535
    t.string   "logo",           limit: 255
    t.string   "facebook",       limit: 255
    t.string   "twitter",        limit: 255
    t.string   "google_plus",    limit: 255
    t.integer  "association_id", limit: 4
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "instagram",      limit: 255
    t.string   "sport",          limit: 255,   default: "soccer"
    t.string   "youtube",        limit: 255
    t.string   "twitter_widget", limit: 255
  end

  add_index "clubs", ["association_id"], name: "index_clubs_on_association_id", using: :btree

  create_table "contact_details", force: :cascade do |t|
    t.string   "address1",    limit: 255
    t.string   "address2",    limit: 255
    t.string   "address3",    limit: 255
    t.string   "suburb",      limit: 255
    t.string   "state",       limit: 255
    t.string   "zipcode",     limit: 255
    t.string   "country",     limit: 255
    t.string   "phone1",      limit: 255
    t.string   "phone2",      limit: 255
    t.string   "phone3",      limit: 255
    t.string   "email",       limit: 255
    t.string   "website",     limit: 255
    t.decimal  "latitude",                precision: 15, scale: 10
    t.decimal  "longitude",               precision: 15, scale: 10
    t.string   "google_id",   limit: 255
    t.integer  "parent_id",   limit: 4
    t.string   "parent_type", limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "contact_details", ["parent_type", "parent_id"], name: "index_contact_details_on_parent_type_and_parent_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "divisions", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.text     "description",    limit: 65535
    t.integer  "association_id", limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "divisions", ["association_id"], name: "index_divisions_on_association_id", using: :btree

  create_table "equipment", force: :cascade do |t|
    t.string   "model",          limit: 255
    t.integer  "equipment_type", limit: 4
    t.text     "specialized",    limit: 65535
    t.text     "variations",     limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "brand_id",       limit: 4
  end

  create_table "equipment_photos", force: :cascade do |t|
    t.string  "photo",        limit: 255
    t.integer "equipment_id", limit: 4
  end

  add_index "equipment_photos", ["equipment_id"], name: "index_equipment_photos_on_equipment_id", using: :btree

  create_table "game_links", force: :cascade do |t|
    t.integer "user_id",        limit: 4
    t.integer "linked_to_id",   limit: 4
    t.string  "linked_to_type", limit: 255
    t.integer "kind",           limit: 4,   default: 0, null: false
    t.string  "url",            limit: 255
  end

  add_index "game_links", ["linked_to_type", "linked_to_id"], name: "index_game_links_on_linked_to_type_and_linked_to_id", using: :btree
  add_index "game_links", ["user_id"], name: "index_game_links_on_user_id", using: :btree

  create_table "games", force: :cascade do |t|
    t.string   "ref",             limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "round",           limit: 255
    t.integer  "state",           limit: 4
    t.integer  "association_id",  limit: 4
    t.integer  "home_team_id",    limit: 4
    t.integer  "away_team_id",    limit: 4
    t.integer  "venue_id",        limit: 4
    t.integer  "home_team_score", limit: 4
    t.integer  "away_team_score", limit: 4
    t.text     "specialized",     limit: 65535
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "round_str",       limit: 255
    t.string   "sport",           limit: 255,   default: "soccer"
    t.string   "season",          limit: 255
  end

  add_index "games", ["association_id"], name: "index_games_on_association_id", using: :btree
  add_index "games", ["away_team_id"], name: "index_games_on_away_team_id", using: :btree
  add_index "games", ["home_team_id"], name: "index_games_on_home_team_id", using: :btree
  add_index "games", ["ref"], name: "index_games_on_ref", using: :btree
  add_index "games", ["venue_id"], name: "index_games_on_venue_id", using: :btree

  create_table "leagues", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "association_id", limit: 4
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "sport",          limit: 255, default: "soccer"
    t.boolean  "no_standings",               default: false
  end

  add_index "leagues", ["association_id"], name: "index_leagues_on_association_id", using: :btree

  create_table "media_sections", force: :cascade do |t|
    t.integer "user_id",       limit: 4
    t.string  "title",         limit: 255
    t.string  "image_url",     limit: 255
    t.string  "external_link", limit: 255
    t.string  "description",   limit: 255
  end

  create_table "player_equipments", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.string   "brand",          limit: 255
    t.string   "model",          limit: 255
    t.integer  "equipment_type", limit: 4
    t.text     "specialized",    limit: 65535
    t.string   "colour",         limit: 255
    t.integer  "equipment_id",   limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "player_equipments", ["equipment_id"], name: "index_player_equipments_on_equipment_id", using: :btree
  add_index "player_equipments", ["user_id"], name: "index_player_equipments_on_user_id", using: :btree

  create_table "player_positions", force: :cascade do |t|
    t.integer "position_id", limit: 4
    t.integer "user_id",     limit: 4
  end

  add_index "player_positions", ["position_id"], name: "index_player_positions_on_position_id", using: :btree
  add_index "player_positions", ["user_id"], name: "index_player_positions_on_user_id", using: :btree

  create_table "player_profiles", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.float    "height_ft",        limit: 24
    t.float    "height_in",        limit: 24
    t.float    "height_cm",        limit: 24
    t.float    "weight_kg",        limit: 24
    t.string   "player_no",        limit: 255
    t.integer  "handedness",       limit: 4
    t.text     "biography",        limit: 65535
    t.text     "specialized",      limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "highlights_video", limit: 255
    t.string   "passport1",        limit: 255
    t.string   "passport2",        limit: 255
  end

  create_table "player_results", force: :cascade do |t|
    t.boolean  "played_game"
    t.string   "sport",          limit: 255
    t.integer  "goals",          limit: 4,     default: 0
    t.integer  "own_goals",      limit: 4,     default: 0
    t.integer  "subst_on",       limit: 4,     default: 0
    t.integer  "subst_off",      limit: 4,     default: 0
    t.integer  "home_or_away",   limit: 4,     default: 0, null: false
    t.integer  "minutes_played", limit: 4,     default: 0
    t.text     "specialized",    limit: 65535
    t.integer  "player_id",      limit: 4
    t.integer  "game_id",        limit: 4
    t.integer  "team_id",        limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.text     "notes",          limit: 65535
    t.integer  "rating",         limit: 4
    t.string   "formation",      limit: 255
  end

  add_index "player_results", ["game_id"], name: "index_player_results_on_game_id", using: :btree
  add_index "player_results", ["player_id"], name: "index_player_results_on_player_id", using: :btree
  add_index "player_results", ["team_id"], name: "index_player_results_on_team_id", using: :btree

  create_table "positions", force: :cascade do |t|
    t.string   "position",   limit: 255
    t.string   "sport",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "roles",      limit: 255
  end

  create_table "previous_teams", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "team_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sport_profiles", force: :cascade do |t|
    t.string   "sport",      limit: 255, default: "soccer"
    t.string   "position",   limit: 255
    t.string   "player_no",  limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "sport_profiles", ["user_id"], name: "index_sport_profiles_on_user_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.text     "description",    limit: 65535
    t.string   "location",       limit: 255
    t.integer  "year",           limit: 4,     default: 0,        null: false
    t.integer  "parent_id",      limit: 4
    t.integer  "association_id", limit: 4
    t.integer  "club_id",        limit: 4
    t.integer  "division_id",    limit: 4
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "league_id",      limit: 4
    t.integer  "league_count",   limit: 4,     default: 0
    t.string   "sport",          limit: 255,   default: "soccer"
    t.integer  "display_state",  limit: 4,     default: 2
  end

  add_index "teams", ["association_id"], name: "index_teams_on_association_id", using: :btree
  add_index "teams", ["club_id"], name: "index_teams_on_club_id", using: :btree
  add_index "teams", ["division_id"], name: "index_teams_on_division_id", using: :btree
  add_index "teams", ["parent_id"], name: "index_teams_on_parent_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                           limit: 255,                      null: false
    t.binary   "crypted_password",                limit: 65535
    t.string   "salt",                            limit: 255
    t.string   "remember_me_token",               limit: 255
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token",            limit: 255
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "activation_state",                limit: 255
    t.string   "activation_token",                limit: 255
    t.datetime "activation_token_expires_at"
    t.string   "first_name",                      limit: 255
    t.string   "middle_name",                     limit: 255
    t.string   "last_name",                       limit: 255
    t.string   "nickname",                        limit: 255
    t.date     "dob"
    t.integer  "gender",                          limit: 4,     default: 0,        null: false
    t.string   "nationality",                     limit: 255
    t.integer  "role",                            limit: 4,     default: 0,        null: false
    t.boolean  "agree_terms",                                   default: false,    null: false
    t.string   "position",                        limit: 255
    t.string   "avatar",                          limit: 255
    t.datetime "team_changed_at"
    t.integer  "verified",                        limit: 4,     default: 0,        null: false
    t.integer  "team_id",                         limit: 4
    t.integer  "club_id",                         limit: 4
    t.integer  "association_id",                  limit: 4
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.boolean  "super_admin",                                   default: false
    t.string   "instagram",                       limit: 255
    t.string   "facebook",                        limit: 255
    t.string   "twitter",                         limit: 255
    t.string   "google_plus",                     limit: 255
    t.string   "linkedin",                        limit: 255
    t.string   "youtube",                         limit: 255
    t.string   "tumblr",                          limit: 255
    t.string   "blog_url",                        limit: 255
    t.string   "active_sport",                    limit: 255,   default: "soccer"
    t.string   "snapchat",                        limit: 255
    t.integer  "reputation_score",                limit: 4,     default: 0,        null: false
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "last_login_from_ip_address",      limit: 255
    t.string   "entered_club_name",               limit: 255
    t.string   "entered_team_name",               limit: 255
    t.string   "entered_league_name",             limit: 255
    t.text     "entered_website",                 limit: 65535
    t.text     "entered_additional_info",         limit: 65535
  end

  add_index "users", ["activation_token"], name: "index_users_on_activation_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at", using: :btree
  add_index "users", ["remember_me_token"], name: "index_users_on_remember_me_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree

  add_foreign_key "equipment_photos", "equipment"
  add_foreign_key "game_links", "users"
  add_foreign_key "leagues", "associations"
  add_foreign_key "player_equipments", "equipment"
  add_foreign_key "player_positions", "positions"
  add_foreign_key "player_positions", "users"
  add_foreign_key "player_results", "games"
  add_foreign_key "player_results", "teams"
  add_foreign_key "player_results", "users", column: "player_id"
  add_foreign_key "sport_profiles", "users"
end
