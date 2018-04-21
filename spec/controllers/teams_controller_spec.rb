require 'rails_helper'

describe TeamsController do

  fixtures :users, :clubs, :teams, :divisions

  before :each do
    @controller.auto_login(users(:nigel))
  end

  it '#index (from club)' do
    get :index, format: :json, club_id: clubs(:oakleigh_cannons_fc).id
    teams = assigns(:teams)
    expect(teams).to be_an(ActiveRecord::Relation)
    expect(teams).to include(teams(:oakleigh_senior_mens))
    expect(response).to be_success
  end

  it '#index (from division)' do
    get :index, format: :json, division_id: divisions(:senior_mens).id
    teams = assigns(:teams)
    expect(teams).to be_an(ActiveRecord::Relation)
    expect(teams).to include(teams(:oakleigh_senior_mens))
    expect(response).to be_success
  end

  it '#create' do
    team = FactoryGirl.build(:team)
    post :create, team.attributes, format: :json
    created = assigns(:team)
    expect(created).to have_attributes(name: 'name', description: 'description', location: 'Melbourne, Victoria')
    expect(created).to be_valid
    expect(created).to_not be_persisted
    expect(response.code).to eq('403')
  end

  it '#create, with super-admin' do
    @controller.auto_login(users(:superadmin))
    team = FactoryGirl.build(:team)
    post :create, team.attributes, format: :json
    created = assigns(:team)
    expect(created).to have_attributes(name: 'name', description: 'description', location: 'Melbourne, Victoria')
    expect(created).to be_valid
    expect(created).to be_persisted
    expect(response).to be_success
  end

  it '#update' do
    team = FactoryGirl.create(:team)
    post :update, {id: team.id, name: 'updated name', description: 'updated description',
                                location: 'updated location'}, format: :json
    created = assigns(:team)
    #expect(created).to have_attributes(name: 'updated name', description: 'updated description', location: 'updated location')
    expect(created).to be_valid
    expect(response.code).to eq('403')
  end

  it '#update, with super-admin' do
    @controller.auto_login(users(:superadmin))
    team = FactoryGirl.create(:team)
    post :update, {id: team.id, name: 'updated name', description: 'updated description',
                   location: 'updated location'}, format: :json
    created = assigns(:team)
    expect(created).to have_attributes(name: 'updated name', description: 'updated description', location: 'updated location')
    expect(created).to be_valid
    expect(response).to be_success
  end

  it '#show' do
    get :show, id: teams(:oakleigh_senior_mens).id, format: :json
    team = assigns(:team)
    expect(team).to be_a(Team)
    expect(team).to eq(teams(:oakleigh_senior_mens))
    expect(response).to be_success
  end

  it '#destroy' do
    team = FactoryGirl.create(:team)
    post :destroy, {id: team.id}, format: :json
    destroyed = assigns(:team)
    expect(destroyed).to be_persisted
    expect(response.code).to eq('403')
  end

  it '#destroy, with super-admin' do
    @controller.auto_login(users(:superadmin))
    team = FactoryGirl.create(:team)
    post :destroy, {id: team.id}, format: :json
    destroyed = assigns(:team)
    expect(destroyed).to_not be_persisted
    expect(response).to be_success
  end
end
