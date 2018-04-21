class PlayerEquipment < ActiveRecord::Base

  enum equipment_type: {boots: 1, guards: 2, gloves: 3, shinpads: 4, unknown: 2**31-1 }

  belongs_to :player, class_name: 'User', foreign_key: 'user_id'
  belongs_to :equipment
end