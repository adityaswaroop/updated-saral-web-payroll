require 'spec_helper'

describe "paymonths/index" do
  before(:each) do
    FactoryGirl.create(:date_format)
    FactoryGirl.create(:option_setting)
    assign(:paymonths, [
      stub_model(Paymonth,
        :month_year => 24144,
        :number_of_days => 31,
        :month_name => "Dec/2011",
        :from_date => "2011-12-01",
        :to_date => "2011-12-31"
      ),
      stub_model(Paymonth,
        :month_year => 24145,
        :number_of_days => 31,
        :month_name => "Jan/2012",
        :from_date => "2012-01-01",
        :to_date => "2012-01-31"
      )
    ]).stub!(:total_pages).and_return(0)
    assign(:count,2)
  end

  it "renders a list of paymonths" do
    render
    ## Run the generator again with the --webrat flag if you want to use webrat matchers
    #assert_select "tr>td", :text => 24144.to_s, :count => 1
    ## Run the generator again with the --webrat flag if you want to use webrat matchers
    #assert_select "tr>td", :text => 31.to_s, :count => 2
    ## Run the generator again with the --webrat flag if you want to use webrat matchers
    #assert_select "tr>td", :text => "Dec/2011".to_s, :count => 1
  end
end
