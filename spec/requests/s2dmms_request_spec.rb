require 'rails_helper'

RSpec.describe "S2dmms", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get "/s2dmms/index"
      expect(response).to have_http_status(:success)
    end
  end

end
