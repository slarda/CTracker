require 'rails_helper'

describe User do

  fixtures :users

  it 'should have Rails associations' do
    user = users(:nigel)
    expect(user).to have_attributes(first_name: 'Nigel', last_name: 'Sheridan-Smith', email: 'nigel@greenshoresdigital.com')
    expect(user).to belong_to(:assoc)
    expect(user).to belong_to(:club)
    expect(user).to belong_to(:team)
    expect(user).to have_one(:player_profile)
  end

end
