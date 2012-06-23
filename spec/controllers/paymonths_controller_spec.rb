require 'spec_helper'

describe PaymonthsController do

  # This should return the minimal set of attributes required to create a valid
  # Paymonth. As you add validations to Paymonth, be sure to
  # update the return value of this method accordingly.
  before :each do
    controller.stub(:logged_in?).and_return(true)
  end
  def valid_attributes
    {
        :month_year => 24144,
        :number_of_days => 31,
        :from_date => "2011-12-01",
        :to_date => "2011-12-31",
        :month_name => "Dec/2011"
    }
  end

  describe "GET index" do
    it "assigns all paymonths as @paymonths" do
      paymonth = Paymonth.create! valid_attributes
      get :index
      assigns(:paymonths).should eq([paymonth])
    end
  end

  describe "GET show" do
    it "assigns the requested paymonth as @paymonth" do
      paymonth = Paymonth.create! valid_attributes
      get :show, :id => paymonth.id
      assigns(:paymonth).should eq(paymonth)
    end
  end

  describe "GET new" do
    it "assigns a new paymonth as @paymonth" do
    option_setting = FactoryGirl.create(:option_setting)
    get :new
      assigns(:paymonth).should be_a_new(Paymonth)
    end
  end

  describe "POST save" do
    it "updates the default month and locked month for the existing paymonths" do
      paymonth_first = FactoryGirl.create(:paymonth)
      paymonth_sec = FactoryGirl.create(:paymonth,:month_name=>'Jan/2011')
      post :save, "paymonth"=>{"0"=>{"paymonth_id"=>"#{paymonth_first.id}", "Lock_Month"=>"true", "default_month"=>"false"}, "1"=>{"paymonth_id"=>"#{paymonth_sec.id}", "Lock_Month"=>"true", "default_month"=>"true"}}
      Paymonth.first.month_locked.should be(true)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Paymonth" do
        expect {
          post :create, "paymonth"=>{"month_name"=>"feb/2011"}
        }.to change(Paymonth, :count).by(1)
      end

      it "assigns a newly created paymonth as @paymonth" do
        post :create, "paymonth"=>{"month_name"=>"feb/2011"}
        assigns(:paymonth).should be_a(Paymonth)
        assigns(:paymonth).should be_persisted
      end

      it "redirects to the created paymonth" do
        post :create, "paymonth"=>{"month_name"=>"feb/2011"}
        response.should redirect_to(paymonths_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved paymonth as @paymonth" do
        # Trigger the behavior that occurs when invalid params are submitted
        Paymonth.any_instance.stub(:save).and_return(false)
        post :create, "paymonth"=>{"month_name"=>"feb/2011"}
        assigns(:paymonth).should be_a_new(Paymonth)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Paymonth.any_instance.stub(:save).and_return(false)
        post :create, "paymonth"=>{"month_name"=>"feb/2011"}
        response.should render_template("new")
      end

      it "re-renders the 'new' template if entered month is not in sequence" do
        # Trigger the behavior that occurs when invalid params are submitted
        Paymonth.any_instance.stub(:save).and_return(false)
        Paymonth.create! valid_attributes.merge(:month_name => "jan/2011")
        post :create, "paymonth"=>{"month_name"=>"Mar/2011"}
        response.should render_template("new")
      end

      it "re-renders the 'new' template if month is mis spelled" do
        # Trigger the behavior that occurs when invalid params are submitted
        Paymonth.any_instance.stub(:save).and_return(false)
        post :create, "paymonth"=>{"month_name"=>"fab/2011"}
        response.should render_template("new")
      end

    end
  end

  describe "DELETE destroy" do
    it "destroys the requested paymonth" do
      paymonth = Paymonth.create! valid_attributes
      expect {
        delete :destroy, :id => paymonth.id
      }.to change(Paymonth, :count).by(-1)
    end

    it "redirects to the paymonths list" do
      paymonth = Paymonth.create! valid_attributes
      delete :destroy, :id => paymonth.id
      response.should redirect_to(paymonths_url)
    end

    it "redirects to the paymonths list is except first or last month is try to destroy" do
      paymonth_jan = Paymonth.create! valid_attributes.merge(:month_name => "jan/2011")
      paymonth_feb = Paymonth.create! valid_attributes.merge(:month_name => "feb/2011")
      paymonth_mar = Paymonth.create! valid_attributes.merge(:month_name => "mar/2011")
      paymonth = Paymonth.create! valid_attributes
      delete :destroy, :id => paymonth_feb.id
      response.should redirect_to(paymonths_url)
    end

    it "does not allow to delete" do
      pf_group_rate = FactoryGirl.create(:pf_group_rate)
      delete :destroy, :id => pf_group_rate.paymonth_id
      assigns(:paymonth).errors.size.should == 1
    end

  end

end
