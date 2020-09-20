require 'rails_helper'

RSpec.describe "S3bases", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get "/s3bases/index"
      expect(response).to have_http_status(:success)
    end
  end

end
