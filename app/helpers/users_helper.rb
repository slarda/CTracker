module UsersHelper

  def player_equipment_sort(equipment)
    equipment.all.sort { |x,y| (x.brand.eql?(y.brand)) ? (x.model.casecmp(y.model)) : (x.brand.casecmp(y.brand)) }
  end

end