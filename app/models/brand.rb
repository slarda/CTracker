class Brand < ActiveRecord::Base

  has_many :equipments

  # Logo support
  mount_uploader :logo, AvatarUploader

end
