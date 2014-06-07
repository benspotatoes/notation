require 'rails_helper'

describe Entry do
  it 'can be created' do
    entry = Entry.create!(
      user_id: 1,
      entry_type: :note)

    expect(entry).to be_an_instance_of(Entry)
  end
end