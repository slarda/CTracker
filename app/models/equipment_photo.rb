class EquipmentPhoto < ActiveRecord::Base

  belongs_to :equipment

  # Equipment photos
  mount_uploader :photo, AvatarUploader

end