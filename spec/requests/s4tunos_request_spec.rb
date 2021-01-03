require 'rails_helper'

RSpec.describe "S4tunos", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get "/s4tunos/index"
      expect(response).to have_http_status(:success)
    end
  end

end
