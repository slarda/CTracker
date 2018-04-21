require 'rails_helper'

describe AssociationsController, type: :controller do

  fixtures :users, :associations

  before :each do
    @controller.auto_login(users(:nigel))
  end

  it '#index' do
    get :index, format: :json
    associations = assigns(:associations)
    expect(associations).to be_an(ActiveRecord::Relation)
    expect(associations).to include(associations(:ffv))
    expect(response).to be_success
  end

  it '#create' do
    association = FactoryGirl.build(:association)
    post :create, association.attributes, format: :json
    created = assigns(:association)
    #expect(created).to have_attributes(name: 'name', description: 'description', location: 'Melbourne, Australia',
    #                                   url: 'http://www.thatsmelbourne.com')
    expect(created).to be_valid
    expect(response.code).to eq('403')
  end

  it '#create, with super-admin' do
    @controller.auto_login(users(:superadmin))
    association = FactoryGirl.build(:association)
    post :create, association.attributes, format: :json
    created = assigns(:association)
    expect(created).to have_attributes(name: 'name', description: 'description', location: 'Melbourne, Australia',
                                       url: 'http://www.thatsmelbourne.com')
    expect(created).to be_valid
    expect(response).to be_success
  end

  it '#update' do
    association = FactoryGirl.create(:association)
    post :update, {id: association.id, name: 'updated name', description: 'updated description',
                   location: 'updated location', url: 'updated url'}, format: :json
    created = assigns(:association)
    #expect(created).to have_attributes(name: 'updated name', description: 'updated description',
    #                                   location: 'updated location', url: 'updated url')
    expect(created).to be_valid
    expect(response.code).to eq('403')
  end

  it '#update, with super-admin' do
    @controller.auto_login(users(:superadmin))
    association = FactoryGirl.create(:association)
    post :update, {id: association.id, name: 'updated name', description: 'updated description',
                   location: 'updated location', url: 'updated url'}, format: :json
    created = assigns(:association)
    expect(created).to have_attributes(name: 'updated name', description: 'updated description',
                                       location: 'updated location', url: 'updated url')
    expect(created).to be_valid
    expect(response).to be_success
  end

  it '#show' do
    get :show, id: associations(:ffv).id, format: :json
    association = assigns(:association)
    expect(association).to be_a(Association)
    expect(association).to eq(associations(:ffv))
    expect(response).to be_success
  end

  it '#destroy' do
    association = FactoryGirl.create(:association)
    post :destroy, {id: association.id}, format: :json
    destroyed = assigns(:association)
    expect(destroyed).to be_persisted
    expect(response.code).to eq('403')
  end

  it '#destroy, with super-admin' do
    @controller.auto_login(users(:superadmin))
    association = FactoryGirl.create(:association)
    post :destroy, {id: association.id}, format: :json
    destroyed = assigns(:association)
    expect(destroyed).to_not be_persisted
    expect(response).to be_success
  end

end
