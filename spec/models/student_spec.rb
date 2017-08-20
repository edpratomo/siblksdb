require 'rails_helper'
require 'pp'

RSpec.describe Student do
  it "knows full names" do
    bart = FactoryGirl.create(:bart, registered_at: DateTime.now.in_time_zone.to_date)
    expect(bart.name).to eq "Bart Simpson"
  end

  it "knows full names" do
    lisa = FactoryGirl.create(:lisa, registered_at: DateTime.now.in_time_zone.to_date)
    expect(lisa.name).to eq "Lisa Simpson"
  end

  it "foobar" do
    msword = FactoryGirl.create(:msword)
    expect(msword.program.program).to eq "Microsoft Office"
  end
  
  it "xyz" do
    stdr = FactoryGirl.create(:students_record)
    expect(stdr.status).to eq "active"
  end
end
