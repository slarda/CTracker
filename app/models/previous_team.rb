class PreviousTeam < ActiveRecord::Base

  # Users can have multiple teams, e.g. multiple years, multiple seasons in a year, multiple sports??
  # There is one active 'team' that is demoted to a 'previous team' once a new active team is defined

  belongs_to :user
  belongs_to :team
end
