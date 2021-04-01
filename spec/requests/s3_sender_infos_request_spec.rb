require 'rails_helper'

RSpec.describe "S3SenderInfos", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get "/s3_sender_infos/index"
      expect(response).to have_http_status(:success)
    end
  end

end
