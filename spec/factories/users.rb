FactoryGirl.define do

  sequence :email do |n|
    "person#{Random.new.rand(10000)}@test.com"
  end

  factory :user do
    email
    password 'test'
    #crypted_password 'password_hash'
    #salt 'salt'
    first_name 'first_name'
    last_name 'last_name'
    gender :unknown_gender
    role :player
    agree_terms true
    disable_notification true
  end
end
