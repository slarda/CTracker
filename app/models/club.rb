class Club < ActiveRecord::Base

  belongs_to :assoc,      class_name: 'Association', foreign_key: 'association_id'
  has_many :teams,        dependent: :destroy
  has_many :participants, class_name: 'User', dependent: :nullify
  has_one :location,      class_name: 'ContactDetail', as: :parent

  accepts_nested_attributes_for :location

  # Logo support
  mount_uploader :logo, AvatarUploader

end
