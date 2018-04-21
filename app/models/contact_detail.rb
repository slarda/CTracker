class ContactDetail < ActiveRecord::Base

  belongs_to :parent, polymorphic: true
  has_many :games

  def full_address
    # TODO: Australian-style addresses only at this time
    a1 = []
    a1 << address1 if address1.present?
    a1 << address2 if address2.present?
    a1 << address3 if address3.present?
    a2 = []
    a2 << suburb if suburb.present?
    a2 << state if state.present?
    a2 << zipcode if zipcode.present?
    a1 << a2.join('  ') unless a2.empty?
    a1 << country if country.present?
    a1.join(', ')
  end

  def combined_phones
    a1 = []
    a1 << phone1 if phone1.present?
    a1 << phone2 if phone2.present?
    a1 << phone3 if phone3.present?
    a1.join(', ')
  end

end
