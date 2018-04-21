require 'rails_helper'

describe UsersController do

  fixtures :users, :clubs, :teams

  before (:each) do
    @controller.auto_login(users(:nigel))
  end


  it '#index' do
    get :index, format: :json
    users = assigns(:users)
    expect(users).to be_nil
    expect(response.code).to eq('403')
  end

  it '#index, with superadmin user' do
    @controller.auto_login(users(:superadmin))
    get :index, format: :json
    users = assigns(:users)
    expect(users).to be_an(ActiveRecord::Relation)
    expect(users).to include(users(:nigel))
    expect(response).to be_success
  end

  it '#create' do
    user = FactoryGirl.build(:user)
    post :create, user.attributes.merge(role: user.role, gender: user.gender, password: user.password), format: :json
    created = assigns(:user)
    expect(created).to have_attributes(first_name: 'first_name', last_name: 'last_name')
    expect(created).to be_valid
  end

  it '#update' do
    user = FactoryGirl.create(:user)
    @controller.auto_login(user)
    post :update, {id: user.id, first_name: 'updated first name', last_name: 'updated last name',
                   active_sport_profile: {sport: 'tennis', player_no: 'L', position: 'Lead'}, format: :json}
    created = assigns(:user)
    expect(created).to have_attributes(first_name: 'updated first name', last_name: 'updated last name')
    expect(created).to be_valid
    expect(response).to be_success
  end

  it '#update, different user' do
    user = FactoryGirl.create(:user)
    post :update, {id: user.id, first_name: 'updated first name', last_name: 'updated last name'}, format: :json
    created = assigns(:user)
    expect(created).to have_attributes(first_name: 'first_name', last_name: 'last_name')
    expect(created).to be_valid
    expect(response.code).to eq('403')
  end

  it '#show' do
    get :show, id: users(:nigel).id, format: :json
    user = assigns(:user)
    expect(user).to be_a(User)
    expect(user).to eq(users(:nigel))
    expect(response).to be_success
  end

  it '#destroy' do
    user = FactoryGirl.create(:user)
    post :destroy, {id: user.id}, format: :json
    destroyed = assigns(:user)
    expect(destroyed).to be_persisted
    expect(response.code).to eq('403')
  end

  it '#destroy, with super-admin' do
    @controller.auto_login(users(:superadmin))
    user = FactoryGirl.create(:user)
    post :destroy, {id: user.id}, format: :json
    destroyed = assigns(:user)
    expect(destroyed).to_not be_persisted
    expect(response).to be_success
  end

  it '#update_club' do
    post :update_club, club_id: clubs(:oakleigh_cannons_fc).id, format: :json
    user = @controller.current_user
    club = assigns(:club)
    expect(user.club).to eq(club)
    expect(user.assoc).to eq(club.assoc)
    expect(response).to be_success
  end

  it '#update_team' do
    post :update_team, team_id: teams(:oakleigh_senior_mens).id, format: :json
    user = @controller.current_user
    team = assigns(:team)
    expect(user.team).to eq(team)
    expect(response).to be_success
  end

end
