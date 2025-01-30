require 'rails_helper'

RSpec.describe "Api::V1::Cars", type: :request do
  let!(:user) { create(:user) }
  let!(:brand1) { create(:brand, name: "Volkswagen") }
  let!(:brand2) { create(:brand, name: "Toyota") }
  let!(:car1) { create(:car, model: "Golf", brand: brand1, price: 35000) }  
  let!(:car2) { create(:car, model: "Corolla", brand: brand2, price: 40000) } 
  let!(:user_preferred_brand) { create(:user_preferred_brand, user: user, brand: brand1) }

  describe "GET /api/v1/cars" do
    it "returns a successful response" do
      get "/api/v1/cars", params: { user_id: user.id }
      expect(response).to have_http_status(:success)
    end

    it "returns cars matching user preferences" do
      get "/api/v1/cars", params: { user_id: user.id }
      json_response = JSON.parse(response.body)

      expect(json_response.first["brand"]["name"]).to eq("Volkswagen")
    end

    it "filters by brand query" do
      get "/api/v1/cars", params: { user_id: user.id, query: "Toyota" }
      json_response = JSON.parse(response.body)

      expect(json_response.first["brand"]["name"]).to eq("Toyota")
    end

    it "filters by price range" do
      get "/api/v1/cars", params: { user_id: user.id, price_min: 30000, price_max: 36000 }
      json_response = JSON.parse(response.body)

      expect(json_response.first["price"]).to be_between(30000, 36000)
    end

    it "returns 404 if user not found" do
      get "/api/v1/cars", params: { user_id: 9999 }
      expect(response).to have_http_status(:not_found)
    end
  end
end
