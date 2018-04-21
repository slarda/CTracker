require 'rails_helper'

describe ContactDetail do

  fixtures :contact_details

  it 'should have Rails associations' do
    contact = contact_details(:home)
    expect(contact).to have_attributes(address1: 'PO Box 123', address2: "'The View'", address3: 'Attn: Nigel',
                       phone1: '0403 930 963', phone2: '03 8000 0000', suburb: 'Preston', state: 'VIC',
                       country: 'Australia')
    expect(contact).to belong_to(:parent)
    #expect(contact).to have_many(:games)
  end

  it '#full_address' do
    contact = contact_details(:home)
    expect(contact.full_address).to eq("PO Box 123, 'The View', Attn: Nigel, Preston  VIC  3072, Australia")
  end

  it '#combined_phones' do
    contact = contact_details(:home)
    expect(contact.combined_phones).to eq("0403 930 963, 03 8000 0000")
  end

end
