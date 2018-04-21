class Equipment < ActiveRecord::Base

  enum equipment_type: {boots: 1, guards: 2, gloves: 3, shinpads: 4, unknown: 2**31-1 }

  belongs_to :brand
  has_many :equipment_photos
  has_many :player_equipments
  has_many :players, through: :player_equipments

  # Nested (admin) forms
  accepts_nested_attributes_for :equipment_photos, allow_destroy: true

  # Serialize any specialized fields
  serialize :specialized
  serialize :variations

  def specialized_as_yaml
    YAML.dump(specialized)
  end

  def specialized_as_yaml=(yaml)
    self.specialized = YAML.load(yaml)
  end

  def variations_as_yaml
    YAML.dump(variations)
  end

  def variations_as_yaml=(yaml)
    self.variations = YAML.load(yaml)
  end
end