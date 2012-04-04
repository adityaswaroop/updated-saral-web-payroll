require 'spec_helper'

describe SalaryHeadsController do

  before :each do
    controller.stub(:logged_in?).and_return(true)
    SalaryHead.delete_all
  end

  def valid_attributes
    {:head_name => "Basic",
     :short_name => "BASIC",
     :salary_type => "Earnings"
     }
  end

  describe "GET index" do
    it "assigns all salary_heads as @salary_heads" do
      salary_head = SalaryHead.create! valid_attributes
      get :index
      assigns(:salary_heads).should eq([salary_head])
    end
  end

  describe "GET new" do
    it "assigns a new salary_head as @salary_head" do
      get :new
      assigns(:salary_head).should be_a_new(SalaryHead)
    end
  end

  describe "GET edit" do
    it "assigns the requested salary_head as @salary_head" do
      salary_head = SalaryHead.create! valid_attributes
      get :edit, :id => salary_head.id
      assigns(:salary_head).should eq(salary_head)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new SalaryHead" do
        expect {
          post :create, :salary_head => valid_attributes
        }.to change(SalaryHead, :count).by(1)
      end

      it "assigns a newly created salary_head as @salary_head" do
        post :create, :salary_head => valid_attributes
        assigns(:salary_head).should be_a(SalaryHead)
        assigns(:salary_head).should be_persisted
      end

      it "redirects to the created salary_head" do
        post :create, :salary_head => valid_attributes
        response.should redirect_to(salary_heads_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved salary_head as @salary_head" do
        # Trigger the behavior that occurs when invalid params are submitted
        SalaryHead.any_instance.stub(:save).and_return(false)
        post :create, :salary_head => {}
        assigns(:salary_head).should be_a_new(SalaryHead)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        SalaryHead.any_instance.stub(:save).and_return(false)
        post :create, :salary_head => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested salary_head" do
        salary_head = SalaryHead.create! valid_attributes
        # Assuming there are no other salary_heads in the database, this
        # specifies that the SalaryHead created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        SalaryHead.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => salary_head.id, :salary_head => {'these' => 'params'}
      end

      it "assigns the requested salary_head as @salary_head" do
        salary_head = SalaryHead.create! valid_attributes
        put :update, :id => salary_head.id, :salary_head => valid_attributes
        assigns(:salary_head).should eq(salary_head)
      end

      it "redirects to the salary_head" do
        salary_head = SalaryHead.create! valid_attributes
        put :update, :id => salary_head.id, :salary_head => valid_attributes
        response.should redirect_to(salary_heads_url)
      end
    end

    describe "with invalid params" do
      it "assigns the salary_head as @salary_head" do
        salary_head = SalaryHead.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        SalaryHead.any_instance.stub(:save).and_return(false)
        put :update, :id => salary_head.id, :salary_head => {}
        assigns(:salary_head).should eq(salary_head)
      end

      it "re-renders the 'edit' template" do
        salary_head = SalaryHead.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        SalaryHead.any_instance.stub(:save).and_return(false)
        put :update, :id => salary_head.id, :salary_head => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested salary_head" do
      salary_head = SalaryHead.create! valid_attributes
      expect {
        delete :destroy, :id => salary_head.id
      }.to change(SalaryHead, :count).by(-1)
    end

    it "redirects to the salary_heads list" do
      salary_head = SalaryHead.create! valid_attributes
      delete :destroy, :id => salary_head.id
      response.should redirect_to(salary_heads_url)
    end
  end

end
