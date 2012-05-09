require "spec_helper"

describe CompanyDocumentsController do
  describe "routing" do

    it "routes to #index" do
      get("/company_documents").should route_to("company_documents#index")
    end

    it "routes to #new" do
      get("/company_documents/new").should route_to("company_documents#new")
    end

    it "routes to #show" do
      get("/company_documents/1").should route_to("company_documents#show", :id => "1")
    end

    it "routes to #edit" do
      get("/company_documents/1/edit").should route_to("company_documents#edit", :id => "1")
    end

    it "routes to #create" do
      post("/company_documents").should route_to("company_documents#create")
    end

    it "routes to #update" do
      put("/company_documents/1").should route_to("company_documents#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/company_documents/1").should route_to("company_documents#destroy", :id => "1")
    end

  end
end
