require 'rails_helper'

describe Association do

  fixtures :associations

  it 'should have Rails associations' do
    association = associations(:ffv)
    expect(association).to have_attributes(name: "Football Federation Victoria", description: 'The mighty Football Federation Victoria')
    expect(association).to have_many(:clubs)
    expect(association).to have_many(:divisions)
    expect(association).to have_many(:participants)
    expect(association).to have_many(:games)
  end

end
