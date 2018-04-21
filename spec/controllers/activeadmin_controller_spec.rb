require 'rails_helper'

describe 'ActiveAdmin controllers' do

  fixtures :all

  context 'Users' do
    before :all do
      @controller = ::Admin::UsersController.new
    end

    it 'are rendered on index page' do
      sign_in admin_users(:admin_nigel)
      get :index
      expect(response).to be_success
      assert_template 'active_admin/resource/index'
    end

    it 'are rendered on item page' do
      sign_in admin_users(:admin_nigel)
      get :show, id: users(:nigel).id
      expect(response).to be_success
      assert_template 'active_admin/resource/show'
    end
  end

  context 'Associations' do
    before :all do
      @controller = ::Admin::AssociationsController.new
    end

    it 'are rendered on index page' do
      sign_in admin_users(:admin_nigel)
      get :index
      expect(response).to be_success
      assert_template 'active_admin/resource/index'
    end

    it 'are rendered on item page' do
      sign_in admin_users(:admin_nigel)
      get :show, id: associations(:ffv).id
      expect(response).to be_success
      assert_template 'active_admin/resource/show'
    end
  end

  context 'Clubs' do
    before :all do
      @controller = ::Admin::ClubsController.new
    end

    it 'are rendered on index page' do
      sign_in admin_users(:admin_nigel)
      get :index
      expect(response).to be_success
      assert_template 'active_admin/resource/index'
    end

    it 'are rendered on item page' do
      sign_in admin_users(:admin_nigel)
      get :show, id: clubs(:oakleigh_cannons_fc).id
      expect(response).to be_success
      assert_template 'active_admin/resource/show'
    end
  end

  context 'Teams' do
    before :all do
      @controller = ::Admin::TeamsController.new
    end

    it 'are rendered on index page' do
      sign_in admin_users(:admin_nigel)
      get :index
      expect(response).to be_success
      assert_template 'active_admin/resource/index'
    end

    it 'are rendered on item page' do
      sign_in admin_users(:admin_nigel)
      get :show, id: teams(:oakleigh_senior_mens).id
      expect(response).to be_success
      assert_template 'active_admin/resource/show'
    end
  end

end
