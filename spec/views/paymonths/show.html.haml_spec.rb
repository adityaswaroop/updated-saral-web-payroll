require 'spec_helper'

describe "paymonths/show" do
  before(:each) do
    @paymonth = assign(:paymonth, stub_model(Paymonth,
      :month_year => 1,
      :number_of_days => 1,
      :month_name => "Jan/2012" ,
      :from_date => '2012-01-01',
      :to_date => '2012-01-31',
      :default_month => 'true',
      :month_locked => 'true'

    ))
  end
  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Month Name/)
  end
end
