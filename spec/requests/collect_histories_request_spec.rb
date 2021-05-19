require 'rails_helper'

RSpec.describe "CollectHistories", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get "/collect_histories/index"
      expect(response).to have_http_status(:success)
    end
  end

end
