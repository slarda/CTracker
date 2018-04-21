require 'rails_helper'

describe Team do

  fixtures :teams

  it 'should have Rails associations' do
    team = teams(:oakleigh_senior_mens)
    expect(team).to have_attributes(name: "Oakleigh Senior Men's", description: "Senior Men's at Oakleigh")
    expect(team).to belong_to(:assoc)
    expect(team).to belong_to(:club)
    expect(team).to belong_to(:division)
    expect(team).to have_many(:players)
    expect(team).to have_many(:home_games)
    expect(team).to have_many(:away_games)
  end

end
