require 'rails_helper'

describe Club do

  fixtures :clubs

  it 'should have Rails associations' do
    club = clubs(:oakleigh_cannons_fc)
    expect(club).to have_attributes(name: 'Oakleigh Cannons FC', description: 'The Oakleigh Cannons')
    expect(club).to belong_to(:assoc)
    expect(club).to have_many(:teams)
    expect(club).to have_many(:participants)
    expect(club).to have_one(:location)
  end

end
