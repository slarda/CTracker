require 'rails_helper'

describe ClubsController do

  fixtures :users, :associations, :clubs

  before :each do
    @controller.auto_login(users(:nigel))
  end

  it '#index (from association)' do
    get :index, association_id: associations(:ffv).id, format: :json
    clubs = assigns(:clubs)
    expect(clubs).to be_an(ActiveRecord::Relation)
    expect(clubs).to include(clubs(:oakleigh_cannons_fc))
    expect(response).to be_success
  end

  it '#index (from first letter uppercase)' do
    get :index, letter: 'O', format: :json
    clubs = assigns(:clubs)
    expect(clubs).to be_an(ActiveRecord::Relation)
    expect(clubs).to include(clubs(:oakleigh_cannons_fc))
    expect(response).to be_success
  end

  it '#index (from first letter lowercase)' do
    get :index, letter: 'o', format: :json
    clubs = assigns(:clubs)
    expect(clubs).to be_an(ActiveRecord::Relation)
    expect(clubs).to include(clubs(:oakleigh_cannons_fc))
    expect(response).to be_success
  end

  it '#create' do
    club = FactoryGirl.build(:club)
    post :create, club.attributes, format: :json
    created = assigns(:club)
    expect(created).to have_attributes(name: 'name', description: 'description')
    expect(created).to be_valid
    expect(created).to_not be_persisted
    expect(response.code).to eq('403')
  end

  it '#create, with super-admin' do
    @controller.auto_login(users(:superadmin))
    club = FactoryGirl.build(:club)
    post :create, club.attributes, format: :json
    created = assigns(:club)
    expect(created).to have_attributes(name: 'name', description: 'description')
    expect(created).to be_valid
    expect(created).to be_persisted
    expect(response).to be_success
  end

  it '#update' do
    club = FactoryGirl.create(:club)
    post :update, {id: club.id, name: 'updated name', description: 'updated description'}, format: :json
    created = assigns(:club)
    #expect(created).to have_attributes(name: 'updated name', description: 'updated description')
    expect(created).to be_valid
    expect(response.code).to eq('403')
  end

  it '#update, with super-admin' do
    @controller.auto_login(users(:superadmin))
    club = FactoryGirl.create(:club)
    post :update, {id: club.id, name: 'updated name', description: 'updated description'}, format: :json
    created = assigns(:club)
    expect(created).to have_attributes(name: 'updated name', description: 'updated description')
    expect(created).to be_valid
    expect(response).to be_success
  end

  it '#show' do
    get :show, id: clubs(:oakleigh_cannons_fc).id, format: :json
    club = assigns(:club)
    expect(club).to be_a(Club)
    expect(club).to eq(clubs(:oakleigh_cannons_fc))
    expect(response).to be_success
  end

  it '#destroy' do
    club = FactoryGirl.create(:club)
    post :destroy, {id: club.id}, format: :json
    destroyed = assigns(:club)
    expect(destroyed).to be_persisted
    expect(response.code).to eq('403')
  end

  it '#destroy, with super-admin' do
    @controller.auto_login(users(:superadmin))
    club = FactoryGirl.create(:club)
    post :destroy, {id: club.id}, format: :json
    destroyed = assigns(:club)
    expect(destroyed).to_not be_persisted
    expect(response).to be_success
  end

end
