class Association < ActiveRecord::Base
  has_many :clubs,          dependent: :destroy
  has_many :divisions,      dependent: :destroy
  has_many :participants,   class_name: 'User', dependent: :nullify
  has_many :games,          dependent: :nullify
  has_many :leagues,        dependent: :destroy

  # Logo support
  mount_uploader :logo, AvatarUploader
end
