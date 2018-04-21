class SportProfile < ActiveRecord::Base

  belongs_to :user, autosave: false

end
